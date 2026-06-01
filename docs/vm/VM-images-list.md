# VM Images list

Here you can find an actual VM images list for different platforms. Please do not forget to check SHA-256 Hash of downloaded images. You can use a https://images.hin.ch/vm-images/SHA256SUMS file to compare it.

??? info "How to perform SHA256 Hash check locally"

    You can calculate SHA256 Hash of downloaded files by following command and then compare it with values in a table below.

    === "Linux and MacOS"

        Open Terminal and execute:

        ```bash
        sha256sum <File Name>
        ```

        As move advanced variant you can execute following command and paste predefined Checksum as `SHA256_VALUE` and File Name as `IMAGE_NAME`:

        ```bash
        SHA256_VALUE="" \
        IMAGE_NAME="" \
        echo "$SHA256_VALUE  $IMAGE_NAME" | sudo sha1sum --check --status
        ```

    === "Windows"

        Open Powershell and execute:

        ```powershell
        Get-FileHash "<File Name>"
        ```

        You can add `-Algorithm SHA256` argument to force SHA256 use.

<!-- Script will replace everything AFTER this line -->
| Image name | Image Type | Image Size | Link | SHA256 Checksum |
| :--------- | :--------: | :--------- | :--: | :-------------- |
| `Alma10-202606011202.stargate-9191647.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.mf) | `dd95ae0c1d456f4355c40b3879e694f68b96f8169331980e343e9075f3d44099` |
| `Alma10-202606011202.stargate-9191647.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>836792320 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.ova) | `e9b17c3fa0cdd88a4072dd2021d07cc47128458d6af673997799e1c27770b0a0` |
| `Alma10-202606011202.stargate-9191647.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.ovf) | `1d05c923733a160dbbed37830daaf5d2f83ca0d01babfda285e47cbd0c8be043` |
| `Alma10-202606011202.stargate-9191647.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1334706176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.qcow2) | `4f69ac4a0f1b903a99954a1ed839113de9f99dd46a76e97b94fd31218dd30020` |
| `Alma10-202606011202.stargate-9191647.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.raw) | `e56424c0e55c414d7774016d716bd8c1e9ceded542663e84c0e04de26e541d26` |
| `Alma10-202606011202.stargate-9191647.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>826331633 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.raw.gz) | `2809224084391d7aa7df829c21113d01c93c82bdc2b20ea836d2c4702ad80965` |
| `Alma10-202606011202.stargate-9191647.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.vhd) | `9f1c4963f1ec9bec2be7b7f6c4eb8acea4166f2efbf9999409838c8019c6b59b` |
| `Alma10-202606011202.stargate-9191647.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 786M /<br>823545963 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.vhd.gz) | `2a0b3e34c19e583e11332175d455cc0f8498d7faa434f35341a5c246b87895da` |
| `Alma10-202606011202.stargate-9191647.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.vhdx) | `5aaf3f520dd66dc1b3cd8a03a47c707ae077772598e5aa1f0557accf146b66dd` |
| `Alma10-202606011202.stargate-9191647.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>836781568 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011202.stargate-9191647.x86_64.vmdk) | `b83461304e6f623a8ccd0d997189f1547a7456c084cb1bc326b15abaf962da11` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `6022431e25f692da79bdfdaab3ec7e32a8903150fe53c8e04a4ca109f74f00b3` |

<!-- Script will replace everything BEFORE this line -->
