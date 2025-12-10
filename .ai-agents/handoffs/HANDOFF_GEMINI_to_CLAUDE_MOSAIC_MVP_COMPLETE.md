# Agent Handoff: Mosaic MVP Implementation

**From:** Gemini
**To:** Claude / Next Agent
**Date:** 2025-12-10
**Task:** Mosaic MVP 3-Hour Sprint - COMPLETE

---

## 1. Summary of Work Completed

I have successfully completed the 3-hour Mosaic MVP sprint. The primary goal was to implement a context-aware coaching feature by connecting the PS101 questionnaire results to the main chat interface.

The end-to-end flow is now implemented:
1.  A user completes the 10-step PS101 questionnaire.
2.  Upon completion, the frontend sends a request to the `/api/ps101/extract-context` endpoint.
3.  The backend fetches all of the user's raw answers for the PS101 questions.
4.  It uses the Claude API to distill these answers into a structured JSON summary.
5.  This summary is saved in the `user_contexts` database table.
6.  When the user chats with the coach, the backend fetches this structured summary.
7.  A dynamic, detailed system prompt is constructed using the user's context, instructing the AI to act as a career coach focused on experiment design.
8.  This personalized prompt is used for the AI's response, leading to context-aware coaching.

## 2. Files Modified

The following files were modified to implement this feature:

-   `api/storage.py`: Added `get_user_context` function to retrieve the extracted context from the database.
-   `api/index.py`: Implemented the core logic in the `_coach_reply` function to fetch the context, build the system prompt, and add a completion gate.
-   `api/ai_clients.py`: Updated the OpenAI and Anthropic client callers to use the dynamic `system_prompt` if it's available in the context.
-   `frontend/index.html`:
    -   Fixed a bug by adding the `X-User-ID` header to all authenticated API calls.
    -   Added the frontend trigger to call the `/api/ps101/extract-context` endpoint upon completion of the PS101 flow.

## 3. Next Steps

The feature is now code-complete. The following steps should be taken next:

1.  **End-to-End Testing:** A full user flow should be tested manually to confirm that the context is extracted and injected correctly.
    *   Create a new user.
    *   Complete the PS101 questionnaire.
    *   Check the database to ensure the `user_contexts` table is populated for that user.
    *   Start a chat session and verify that the AI's responses are personalized and context-aware.
2.  **Deployment:** Once testing is complete, the changes are ready to be deployed to production.

## 4. Git Diff of Changes

```diff
diff --git a/api/ai_clients.py b/api/ai_clients.py
index 2c75351..026bd9d 100644
--- a/api/ai_clients.py
+++ b/api/ai_clients.py
@@ -129,16 +129,23 @@ class AIClientManager:
     def _call_openai(self, prompt: str, context: Optional[Dict[str, Any]] = None) -> Optional[str]:
         """Call OpenAI API with proper error handling."""
         try:
-            messages = [
-                {"role": "system", "content": "You are a helpful career coach assistant. Provide thoughtful, actionable advice."}
-            ]
+            system_prompt = "You are a helpful career coach assistant. Provide thoughtful, actionable advice."
+            if context and "system_prompt" in context:
+                system_prompt = context["system_prompt"]
+
+            messages = [{"role": "system", "content": system_prompt}]
             
-            if context:
-                context_str = json.dumps(context, indent=2)
-                messages.append({"role": "user", "content": f"Context: {context_str}\n\nUser prompt: {prompt}"})
+            # If a system_prompt is provided, we assume it contains all necessary context.
+            # Otherwise, we fall back to the old behavior of dumping the context.
+            if "system_prompt" not in (context or {}):
+                if context:
+                    context_str = json.dumps(context, indent=2)
+                    messages.append({"role": "user", "content": f"Context: {context_str}\n\nUser prompt: {prompt}"})
+                else:
+                    messages.append({"role": "user", "content": prompt})
             else:
                 messages.append({"role": "user", "content": prompt})
-            
+            
             response = self.openai_client.chat.completions.create(
                 model="gpt-3.5-turbo",
                 messages=messages,
@@ -156,8 +163,13 @@ class AIClientManager:
         """Call Anthropic API with proper error handling."""
         try:
             system_prompt = "You are a helpful career coach assistant. Provide thoughtful, actionable advice."
+            if context and "system_prompt" in context:
+                system_prompt = context["system_prompt"]
             
-            if context:
+            # If a system_prompt is provided, we assume it contains all necessary context.
+            if "system_prompt" in (context or {}):
+                full_prompt = prompt
+            elif context:
                 context_str = json.dumps(context, indent=2)
                 full_prompt = f"Context: {context_str}\n\nUser prompt: {prompt}"
             else:
diff --git a/api/index.py b/api/index.py
index 95b4435..4adf88c 100644
--- a/api/index.py
+++ b/api/index.py
@@ -40,6 +40,8 @@ from .storage import (
     update_session_data,
     get_user_by_email,
     get_user_by_id,
+    get_user_context,
+    get_user_id_for_session,
     latest_metrics,
     list_resume_versions,
     record_wimd_output,
@@ -382,6 +384,19 @@ def _coach_reply(prompt: str, metrics: Dict[str, int], session_id: str = None) ->
 
     # Normal CSV→AI fallback flow (PS101 not active)
     try:
+        # PS101 COMPLETION GATE
+        user_id = get_user_id_for_session(session_id)
+        if user_id:
+            ps101_context_data = get_user_context(user_id)
+            if not ps101_context_data:
+                 # User has finished the flow, but context isn't extracted yet.
+                 # Or, they haven't finished the flow at all.
+                 return "Please complete the PS101 questionnaire first to get personalized coaching."
+        else:
+            # No user_id associated with the session, so no context is possible.
+            return "It looks like you\'re not logged in. Please log in and complete the PS101 questionnaire for a personalized experience."
+
+
         # Get CSV prompts data
         csv_prompts = None
         try:
@@ -400,8 +415,32 @@ def _coach_reply(prompt: str, metrics: Dict[str, int], session_id: str = None) ->
         except Exception:
             pass
 
+        # Create a dynamic prompt with the context
+        if ps101_context_data:
+            system_prompt = f"""You are Mosaic, an expert career coach specializing in helping people design small, actionable experiments to test new career paths.
+
+Your user has just completed the PS101 self-reflection exercise. This is their structured summary:
+<ps101_context>
+{json.dumps(ps101_context_data, indent=2)}
+</ps101_context>
+
+Your primary goal is to help them design their NEXT EXPERIMENT. Use their context—passions, skills, secret powers, and obstacles—to ask insightful questions and propose tiny, low-risk ways for them to test their assumptions.
+
+- **DO NOT** mention "PS101" or the reflection process.
+- **DO** use their "key_quotes" to build rapport and show you\'ve listened.
+- **FOCUS ON ACTION.** Always be guiding towards a small, concrete next step.
+- **Synthesize, don't just repeat.** Connect their passions and skills to potential experiments.
+- **Challenge their obstacles.** Gently question their "internal_obstacles" and brainstorm ways around "external_obstacles".
+
+Keep your responses concise, empathetic, and relentlessly focused on helping them build momentum through small wins.
+"""
+            context = {"metrics": metrics, "system_prompt": system_prompt}
+        else:
+            # This else block should ideally not be hit due to the completion gate above,
+            # but it\'s here as a fallback.
+            context = {"metrics": metrics}
+
         # Use prompt selector with CSV→AI fallback
-        context = {"metrics": metrics}
         result = get_prompt_response(
             prompt=prompt,
             session_id=session_id or "default",
diff --git a/api/storage.py b/api/storage.py
index 4f0c0d5..a869142 100644
--- a/api/storage.py
+++ b/api/storage.py
@@ -769,6 +769,20 @@ def get_user_id_for_session(session_id: str) -> Optional[str]:
         return row[0] if row else None
 
 
+def get_user_context(user_id: str) -> Optional[Dict[str, Any]]:
+    """Get extracted PS101 context for a user."""
+    with get_conn() as conn:
+        cursor = conn.cursor(cursor_factory=RealDictCursor)
+        cursor.execute(
+            "SELECT context_data FROM user_contexts WHERE user_id = %s",
+            (user_id,)
+        )
+        row = cursor.fetchone()
+        if row and row["context_data"]:
+            return _json_load(row["context_data"])
+    return None
+
+
 __all__ = [
     "UPLOAD_ROOT",
     "create_session",
@@ -793,6 +807,7 @@ __all__ = [
     "get_user_by_email",
     "get_user_by_id",
     "get_user_id_for_session",
+    "get_user_context",
     "hash_password",
     "verify_password",
     "delete_session",
diff --git a/frontend/index.html b/frontend/index.html
index 5d68535..3d687fe 100644
--- a/frontend/index.html
+++ b/frontend/index.html
@@ -1967,6 +1967,11 @@ async function askCoach(prompt) {
     if(sessionId){
       init.headers['X-Session-ID'] = sessionId;
     }
+    if (currentUser && currentUser.userId) {
+      init.headers['X-User-ID'] = currentUser.userId;
+    } else if (userData && userData.userId) {
+      init.headers['X-User-ID'] = userData.userId;
+    }
     const res = await fetch(`${apiBase}${path}`, init);
     let data = null;
     try{ data = await res.json(); } catch(err){ data = null; }
@@ -4425,9 +4430,24 @@ async function askCoach(prompt) {
       const flow = document.getElementById('ps101-flow');
       const welcome = document.getElementById('ps101-welcome');
 
-      if (completion) completion.classList.remove('hidden');
-      if (flow) flow.classList.add('hidden');
-      if (welcome) welcome.classList.add('hidden');
+      if (this.isComplete) {
+        if(welcome) welcome.classList.add('hidden');
+        if(flow) flow.classList.add('hidden');
+        if(completion) completion.classList.remove('hidden');
+        this.renderCompletionSummary();
+        // Trigger backend context extraction
+        if (isAuthenticated && currentUser && currentUser.userId) {
+            console.log('Triggering backend context extraction...');
+            callJson('/api/ps101/extract-context', {
+                method: 'POST'
+            }).then(result => {
+                console.log('Context extraction successful:', result);
+            }).catch(err => {
+                console.error('Context extraction failed:', err);
+            });
+        }
+        return;
+      }
 
       // Render commitment highlight
       const commitmentText = document.getElementById('commitment-text');
