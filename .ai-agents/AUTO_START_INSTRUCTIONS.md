# Auto-Start Agent Messaging on Terminal Launch

## For Claude Code (Bash/Zsh)

Add to your shell RC file (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):

```bash
# AI Agent Auto-Check Messages
if [ "$PWD" = "/Users/damianseguin/WIMD-Deploy-Project" ]; then
    export AI_AGENT_NAME="Claude-Code"

    # Auto-start broker if not running
    if ! curl -s -f http://localhost:8765/health > /dev/null 2>&1; then
        echo "🚀 Starting message broker..."
        ./scripts/start_broker.sh
    fi

    # Check for messages
    echo ""
    echo "Checking for agent messages..."
    ./scripts/agent_receive.sh
    echo ""
fi
```

## For Claude Code (Using direnv - RECOMMENDED)

Create `.envrc` in project root:

```bash
# /Users/damianseguin/WIMD-Deploy-Project/.envrc

export AI_AGENT_NAME="Claude-Code"

# Auto-start broker
if ! curl -s -f http://localhost:8765/health > /dev/null 2>&1; then
    ./scripts/start_broker.sh
fi

# Check for messages
./scripts/agent_receive.sh
```

Then run: `direnv allow`

**Benefit:** Auto-runs when you CD into the directory

## For Gemini (Browser Console Auto-Run)

If Gemini has browser access, add to browser console:

```javascript
// Auto-check on page load
window.addEventListener('load', async () => {
    const resp = await fetch('http://localhost:8765/messages/Gemini');
    const messages = await resp.json();

    if (messages.length > 0) {
        console.log('📨 You have', messages.length, 'message(s)');
        console.table(messages);
    }
});
```

## For ANY Agent (Shell Init Script)

Create `~/.ai_agent_init.sh`:

```bash
#!/bin/bash
# Auto-run when starting AI agent terminal

PROJECT_DIR="/Users/damianseguin/WIMD-Deploy-Project"

if [ "$PWD" = "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"

    # Ensure broker is running
    if [ ! -f .ai-agents/broker.pid ] || ! ps -p $(cat .ai-agents/broker.pid) > /dev/null 2>&1; then
        ./scripts/start_broker.sh
    fi

    # Auto-check messages
    if [ -n "$AI_AGENT_NAME" ]; then
        ./scripts/agent_receive.sh
    fi
fi
```

Add to `~/.zshrc`:

```bash
source ~/.ai_agent_init.sh
```
