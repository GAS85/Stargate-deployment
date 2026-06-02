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
| `Alma10-202606020646.stargate-4bec188.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 800M /<br>838133760 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.ova) | `1f9d9fce5896c465ccf8802c5452b0a581f476d89e6394cea2b567f54023d245` |
| `Alma10-202606020646.stargate-4bec188.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.mf) | `5d5c2c14c124b1c36cdffe4e87d8cc47646bc7464bdd29cd0c7369627cae9003` |
| `Alma10-202606020646.stargate-4bec188.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.ovf) | `14c1c2683f07bf8575ec09bdb37905dbc42a6bb60ff6ef1b39ee4ab3a27124b8` |
| `Alma10-202606020646.stargate-4bec188.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1338048512 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.qcow2) | `316f8f49a2b06adda014413494b7bf1e3397b463526a9ccfaecb27a7586b8d1c` |
| `Alma10-202606020646.stargate-4bec188.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.raw) | `eb8cd70550b62036ebf51a3f3ddd9ff4b79f5e9902d79210324298e6ced431c5` |
| `Alma10-202606020646.stargate-4bec188.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 790M /<br>827636368 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.raw.gz) | `6f86eb0c525608336dad7e19a0a94fe349eaf90234f816a6c8d5fb7445aa408b` |
| `Alma10-202606020646.stargate-4bec188.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.vhd) | `8fe67ca2d09dc7c64b067d7155c6394ec1bfd4479f3fb58f3e42cb42a2d0ffbf` |
| `Alma10-202606020646.stargate-4bec188.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 788M /<br>825853215 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.vhd.gz) | `efdeb0d18d53383409ac84126cb3bbe5e1f1dc818039e2d8a76e675969b7539c` |
| `Alma10-202606020646.stargate-4bec188.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.vhdx) | `0203820d187d17c2b1f434125561d028680240a13e7850a7ddfa6de1d4637867` |
| `Alma10-202606020646.stargate-4bec188.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 800M /<br>838115840 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020646.stargate-4bec188.x86_64.vmdk) | `43dae805714932259dc5f55d3ba876e1c80e999374ce1a5c4b0fb7bbea4ec1bc` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `abf99c15e35a805e1f15a79227a75ca235e1d13c79b9a6860a95efa7c33b2699` |

<!-- Script will replace everything BEFORE this line -->
