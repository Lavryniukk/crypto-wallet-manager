import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const WalletManagerModule = buildModule("WalletManagerModule", (m) => {
  const wm = m.contract("WalletManager", []);

  return { wm };
});

export default WalletManagerModule;
