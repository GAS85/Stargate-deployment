# VM Images list

Here you can find a current VM images list for different platforms. Please do not forget to check the SHA-256 hash of downloaded images. You can use the https://images.hin.ch/vm-images/SHA256SUMS file to compare it.

??? info "How to perform SHA256 hash check locally"

    You can calculate the SHA256 hash of downloaded files with the following command and then compare it with the values in the table below.

    === "Linux and macOS"

        Open Terminal and execute:

        ```bash
        sha256sum <File Name>
        ```

        As a more advanced variant, you can execute the following command and paste the predefined checksum as `SHA256_VALUE` and the file name as `IMAGE_NAME`:

        ```bash
        SHA256_VALUE="" \
        IMAGE_NAME="" \
        echo "$SHA256_VALUE  $IMAGE_NAME" | sudo sha256sum --check --status
        ```

    === "Windows"

        Open PowerShell and execute:

        ```powershell
        Get-FileHash "<File Name>"
        ```

        You can add the `-Algorithm SHA256` argument to force SHA256 use.

<!-- Script will replace everything AFTER this line -->
| Image name | Image Type | Image Size | Link | SHA256 Checksum |
| :--------- | :--------: | :--------- | :--: | :-------------- |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 961M /<br>1007441920 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.ova) | `6522df82608387965f25ee7706299c30b8027cfb563218695b96a1267a8be07e` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>255 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.mf) | `37ebee53d2ca9611be7d03f6f9f67b1ce89247a0694ee2fc28856549b08cf467` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7684 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.ovf) | `a4719e2a75ef044d31e5f49948f9b4ff8a38569aaaa0f158b3ab7ae1c7d108b7` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1639514112 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.qcow2) | `c9ed530d82a5062162f52a2baf401e0141b4e441efc13ef20485d3bc667bd66a` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.raw) | `f6c4695dcf02d2e148c51bb67c16a7b18d1e6fe77abf8d0e22e1ac542fd1df38` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 969M /<br>1015766980 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.raw.gz) | `bb9c867aef727eccd4be29e7dfcc82425bb62ed5697f85ec1ed6a07f62d8ef65` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhd) | `13169b5bf48749397e3cd77c44e576b6476f4d4d37fcb3c08d9c6d902d1b5057` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 976M /<br>1022626154 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhd.gz) | `095e7289ac0ce486e1927b3d5b927ca781fa5d5d8d9a06a807bc14dc5b19d994` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.1G /<br>2222981120 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vhdx) | `251df6e4280b4fb3245dbd51596608886bb255a5325aed2e2412fe2f4d27c409` |
| `Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 961M /<br>1007421952 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606121259.SGpreprod-v0.5.0-rc4.x86_64.vmdk) | `1692922903eb2321deb4d2ad76313be23b4831fe7dd394265c3ca576c2bb392e` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1209 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `58bb93ae034e55373df964eb4244197fa17a1be6fa0d65a6f1b82c20560178bd` |

<!-- Script will replace everything BEFORE this line -->
