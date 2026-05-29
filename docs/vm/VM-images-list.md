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
| `Alma10-202605291044.stargate-61b251a.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837099520 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.ova) | `2f49ff769d143a1e30796962c716776362e31f29d1a225ef7fd64b5ca9213cd7` |
| `Alma10-202605291044.stargate-61b251a.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.mf) | `fda0194cfb9fe97845f0d48f5c56492d874f77e05e792afe55699637d0fad350` |
| `Alma10-202605291044.stargate-61b251a.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.ovf) | `82f1f1554dcd6682fc5fcdf4f44947fb1a9622ad378586056ba80f555355b242` |
| `Alma10-202605291044.stargate-61b251a.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1336213504 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.qcow2) | `9193336e0f9fda001e2651e019177782cbc32a87bcecb581971af01db76a8636` |
| `Alma10-202605291044.stargate-61b251a.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.raw) | `e0f6a0b330ba2baf174a7e73a6073edfb2761b5dfe29b44cfaab3913300309d7` |
| `Alma10-202605291044.stargate-61b251a.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>826592336 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.raw.gz) | `71dc4455749208bd55423bb8eecf20134efd93f23c747b9b684f4eddbee2b4c7` |
| `Alma10-202605291044.stargate-61b251a.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.vhd) | `40d9b2e607118f4034e698f80bde64473a53ab0e31f53ee0dada807cd94c3edc` |
| `Alma10-202605291044.stargate-61b251a.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 787M /<br>824828894 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.vhd.gz) | `5b758daad6010d9b6bee0a6de3e223468d114d9871df04084b4e0fecbe45852c` |
| `Alma10-202605291044.stargate-61b251a.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.vhdx) | `f788fb79928ff0536abfe9749d8725a017131119a89e9c3a4d60e53a5037ddf1` |
| `Alma10-202605291044.stargate-61b251a.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>837083648 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605291044.stargate-61b251a.x86_64.vmdk) | `0b2c8c25b669f03fe75845e105274d90d1fd752dfdecc80ce33392bb1b8bc9cf` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `cfba357b456c180a44668321f6b1496180b4a8df491e131450e2fce9e336a72f` |

<!-- Script will replace everything BEFORE this line -->
