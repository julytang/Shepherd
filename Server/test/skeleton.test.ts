import { test } from "node:test";
import assert from "node:assert/strict";
import { describeRelay } from "../src/relay/index.ts";
import { describePushGateway } from "../src/push/index.ts";
import { PROTOCOL_VERSION } from "../src/protocol/version.ts";

test("两个程序报告同一个协议版本", () => {
  assert.match(describeRelay(), new RegExp(`v${PROTOCOL_VERSION}`));
  assert.match(describePushGateway(), new RegExp(`v${PROTOCOL_VERSION}`));
});
