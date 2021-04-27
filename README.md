# Auto-Build-OpenWrt

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/molun/Auto-Build-OpenWrt/blob/master/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)](https://github.com/P3TERX/Actions-OpenWrt/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)](https://github.com/P3TERX/Actions-OpenWrt/fork)

Build OpenWrt using GitHub Actions

[Read the details in P3TERX blog (in Chinese) | 中文教程](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

## Status

![Build Lean_LEDE_B70](https://github.com/molun/Auto-Build-OpenWrt/workflows/Build%20Lean_LEDE_B70/badge.svg)
![Build Lean_LEDE_K2P](https://github.com/molun/Auto-Build-OpenWrt/workflows/Build%20Lean_LEDE_K2P/badge.svg)
![Build Lean_LEDE_K2T](https://github.com/molun/Auto-Build-OpenWrt/workflows/Build%20Lean_LEDE_K2T/badge.svg)
![Build Lean_LEDE_HC5962](https://github.com/molun/Auto-Build-OpenWrt/workflows/Build%20Lean_LEDE_HC5962/badge.svg)
![Build Lean_LEDE_Redmi_AC2100](https://github.com/molun/Auto-Build-OpenWrt/workflows/Build%20Lean_LEDE_Redmi_AC2100/badge.svg)


## Usage

- Click the [Use this template](https://github.com/molun/Auto-Build-OpenWrt/generate) button to create a new repository.
- Generate `.config` files using [OpenWrt](https://github.com/openwrt/openwrt)/[Lean's OpenWrt](https://github.com/coolsnowwolf/lede)/[Lienol's OpenWrt](https://github.com/Lienol/openwrt) source code. ( You can change it through environment variables in the workflow file. )
- Push `.config` file to the GitHub repository, and the build starts automatically.Progress can be viewed on the Actions page.
- When the build is complete, click the `Artifacts` button in the upper right corner of the Actions page to download the binaries.

## Acknowledgments

- [Microsoft](https://www.microsoft.com)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub](https://github.com)
- [GitHub Actions](https://github.com/features/actions)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cisco](https://www.cisco.com/)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [Lienol's OpenWrt](https://github.com/Lienol/openwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [Cowtransfer](https://cowtransfer.com)
- [WeTransfer](https://wetransfer.com/)
- [Mikubill/transfer](https://github.com/Mikubill/transfer)

## License

[MIT](https://github.com/molun/Auto-Build-OpenWrt/blob/master/LICENSE) © MOLUN