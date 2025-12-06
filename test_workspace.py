#!/usr/bin/env python3
import sys
sys.path.insert(0, '.')

import os
ws =  "/app/backend/data/workspaces/"
os.environ['CODE_WORKSPACE_ROOT'] = ws

import asyncio
from run_code_tool import Tools

async def test():
    tools = Tools()
    
    # Test with a user
    test_user = {"id": "test_user_123", "name": "Test User"}
    
    print("Testing workspace creation...")
    
    result = await tools.run_python_code(python_code="print('Hello, workspace!')", __user__=test_user)
    
    print("Result:", result)
    
    # Check if directory was created
    import os
    workspace_path = ws + "test_user_123"
    if os.path.exists(workspace_path):
        print(f"✓ Workspace created at: {workspace_path}")
    else:
        print("✗ Workspace not created")

if __name__ == "__main__":
    asyncio.run(test())
