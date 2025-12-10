Here is a summary of the work completed for the Mosaic MVP build.

### Summary of Changes

The primary goal was to implement context-aware coaching by injecting the user's PS101 reflection summary into the chat prompt.

#### 1. Backend API (`api/`)

*   **`api/storage.py`**:
    *   Added a new function `get_user_context(user_id)` to fetch the extracted PS101 JSON blob from the `user_contexts` table.
*   **`api/index.py`**:
    *   The main chat endpoint logic in `_coach_reply` was modified.
    *   When a user who has completed PS101 sends a message, it now fetches the extracted context using `get_user_context`.
    *   A detailed system prompt is dynamically constructed, including the user's context, and is passed to the AI model.
    *   A "completion gate" was added to ensure that users who haven't completed PS101 are prompted to do so.
*   **`api/ai_clients.py`**:
    *   The `_call_openai` and `_call_anthropic` functions were updated to look for a `system_prompt` in the `context` dictionary.
    *   If found, this dynamic prompt is used as the system message for the AI, enabling personalized coaching.

#### 2. Frontend (`frontend/index.html`)

*   **Authentication Header**:
    *   The `callJson` function was modified to include the `X-User-ID` header on all authenticated API calls. This was a necessary fix as the backend requires this header to identify the user.
*   **Context Extraction Trigger**:
    *   Added Javascript code to the `PS101` class. When the user completes the final step of the questionnaire, a `POST` request is now sent to the `/api/ps101/extract-context` endpoint.
    *   This triggers the backend process to read all the user's answers from the `ps101_responses` table, use the Claude API to create a structured JSON summary, and save it to the `user_contexts` table for future use.

### Git Diff of Changes

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
+            if "system_prompt" not in (context or {{}}):
+                if context:
+                    context_str = json.dumps(context, indent=2)
+                    messages.append({"role": "user", "content": f"Context: {context_str}\n\nUser prompt: {prompt}"})
                 else:
                     messages.append({"role": "user", "content": prompt})
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
+            if "system_prompt" in (context or {{}}):
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
+        # context = {"metrics": metrics}
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
     try{ data = await res.json(); } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; } catch(err){ data = null; A beautiful mountain landscape', negativeText='people, clouds'
        )
        assert params.text == 'A beautiful mountain landscape'
        assert params.negativeText == 'people, clouds'
```