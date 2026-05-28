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
| `Alma10-202605281053.stargate-9489a4d.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.mf) | `b87a98d9c1fb6285f02bf857f7326218983798200d870678b32b13edbf897cca` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837171200 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.ova) | `9e5835bcca9a2d3efea47681a92be63084bfef643da5917d36901529a4c7b19c` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.ovf) | `721bca9129062b3702ee7ee865e5f8dbf9390971b8f8c56f35c2e76aff988c40` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1335558144 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.qcow2) | `0408b538377ce94c3bddae6e68ccbc4c559e05d45a3ca7829506a9060651833a` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.raw) | `0ef1a816140a8443502c2b4c181b45943422362b1f3b9bf7703ce0392c028f0a` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>826707970 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.raw.gz) | `e9bd0f5b01a727f3b2b8f19bd96f85067a1abd29ca7d18996001e0ac460ea02b` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.vhd) | `376bc2665dc25e263534b93f3589aa5096752f322d27326cbe3ac27fa282b207` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 786M /<br>823996076 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.vhd.gz) | `7ea4ea3ea0cffd7881827467ce75686ce0a48c46cb29624b60eca18c8b696f6c` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.7G /<br>1820327936 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.vhdx) | `283608c82ca990c8d225d695e3cb21893bcd448663c14137b2058aa8958d8498` |
| `Alma10-202605281053.stargate-9489a4d.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>837152768 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605281053.stargate-9489a4d.x86_64.vmdk) | `1dd8649e29d006eaf27c97a271fd0ce45740eeaa0c8f7a7cb703205b088dd6e5` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `7b8705d976f33f68e46a17ac95ee61eb793a9c6b601127dca8e2bc2d21e9f66b` |

<!-- Script will replace everything BEFORE this line -->
