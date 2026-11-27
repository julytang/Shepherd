// 中继：验证主机密钥、管理设备凭证、对接连接后转发密文。
// 目前只有骨架，协议见 ../../PROTOCOL.md。
import { PROTOCOL_VERSION } from "../protocol/version.ts";

export function describeRelay(): string {
  return `shepherd-relay protocol v${PROTOCOL_VERSION} (skeleton)`;
}

if (import.meta.main) {
  console.log(describeRelay());
}
