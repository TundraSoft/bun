// Fixture used by tests/smoke.sh to verify FILE and SCRIPT run modes.
const port = Number(Bun.env.PORT ?? 8080);

Bun.serve({
  port,
  hostname: "0.0.0.0",
  fetch() {
    return new Response("smoke-fixture-marker\n");
  },
});

console.log("smoke fixture server listening on port " + port);
