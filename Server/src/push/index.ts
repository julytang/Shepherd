// 推送网关：持有 APNs 密钥，只接受已通过主机密钥证明的推送请求。
// 与中继分开部署；自建中继的用户仍然使用官方的推送网关。
// 目前只有骨架，协议见 ../../PROTOCOL.md。
import { PROTOCOL_VERSION } from "../protocol/version.ts";

export function describePushGateway(): string {
  return `shepherd-push protocol v${PROTOCOL_VERSION} (skeleton)`;
}

if (import.meta.main) {
  console.log(describePushGateway());
}
