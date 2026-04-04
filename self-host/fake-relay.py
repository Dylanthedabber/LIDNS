import asyncio
import json
import websockets
import logging
import re

logging.basicConfig(level=logging.INFO)

DOMAIN_LOG = "/tmp/relay-domains.log"

def log_domain(host):
    try:
        with open(DOMAIN_LOG, "a") as f:
            f.write(host + "\n")
    except Exception:
        pass

async def handler(ws):
    path = getattr(ws, 'path', None) or getattr(ws.request, 'path', '/')
    logging.info(f"WS connection from {ws.remote_address} path={path}")

    await ws.send(json.dumps({"action": "live_activity_start", "message": {"heartbeatInterval": 30000}}))
    try:
        async for raw in ws:
            try:
                msg = json.loads(raw)
            except Exception:
                continue
            action = msg.get("action", "")
            host = msg.get("host", "")
            logging.info(f"action={action} host={host}")

            if action == "your_ip":
                await ws.send(json.dumps({"action": "your_ip", "ip": "1.2.3.4"}))

            elif action == "dy_lookup":
                log_domain(host)
                await ws.send(json.dumps({
                    "action": "host_lookup",
                    "cat": 1,
                    "request": {"host": host}
                }))

    except websockets.exceptions.ConnectionClosed as e:
        logging.info(f"Connection closed: {e}")
    except Exception as e:
        logging.info(f"Error: {e}")

async def main():
    async with websockets.serve(handler, "127.0.0.1", 8444, ping_interval=None):
        logging.info("Fake relay running on 127.0.0.1:8444")
        await asyncio.Future()

asyncio.run(main())
