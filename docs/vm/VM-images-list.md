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
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.mf) | `811cff16e693902d1bc2cca82073f1c435b97c9d285ad323a7ca404d63125079` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.ovf) | `f8293ee755517520be846f9cd3db0362b19564f9c4d5dc984fdabc15a09ffb8c` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 931M /<br>975462400 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.ova) | `18d675d4c08114584d29becaedc0850a75cdef658f583c46abe5238185239981` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1614282752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.qcow2) | `ea7750ac88c80918e1ee1f6a57eb25aedbcdae7914e05cc9bfbd5763de74d00d` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.raw) | `96f2ab540684d9ee41617d247d041dd751fd8ba7ebd534c758443a87c08fd673` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 919M /<br>963169573 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.raw.gz) | `e1181f0b645127568fc0aa10fd4d8ab6526522b1907e980946a302eab807f043` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhd) | `dac26723d3e45a424d1caf88ca1843213ddb85440e01009020f8d5588a88a795` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 918M /<br>961967329 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhd.gz) | `3049d35a7e0f97340fca961fdac8845de33431fbe9f38625e54aa6ed178a608f` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.9G /<br>2021654528 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vhdx) | `91fad1527630b019eb14bf97a524676a3bf83775681c0608c30311010f7c10dd` |
| `Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 931M /<br>975442432 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081121.SGpreprod-v0.4.9.x86_64.vmdk) | `a75bc7b6ea88994e944ca9dbac84189827c8fda457067723700bef69a5937ab1` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `d50915f74e0f7420239baf55b3a7b0138d0ac6a8cc46c21fe7d5c55b64ebd85d` |

<!-- Script will replace everything BEFORE this line -->
