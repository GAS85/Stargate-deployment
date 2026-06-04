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
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>283 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.mf) | `415586b2798f2b8b70c788878ff7ed68c0be09ae4ffbe91e01bf225278f2e5c6` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 965M /<br>1011005440 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.ova) | `9bc15decfbb2a965a06fae3c9f340442ce6460969a7e15e659ffc7e9e15e267d` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7698 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.ovf) | `639556e2764350e589b9e433f96ab7c6495a062403ca76fd34a2a59797284f5d` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1652031488 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.qcow2) | `2cdb4994f563843c0a507baed10a175dbb92a19f3166e5cf7166b15c67c60719` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.raw) | `642bae2bd61d4e53a070c114a8989c35b12b6426898d0d2f3d488fae8dda2f66` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 953M /<br>998251079 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.raw.gz) | `e396bc05d882102f6ce099d01ccb4ffd523f63626524664f5e63377d2d0ba3b1` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhd) | `f1df628058830e5550be2459057ed5ac2859c1e153bf9af3d17581ba0f76690a` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 950M /<br>995468530 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhd.gz) | `1acbcc4056c97987f86a8854eaf9152d643374c20199b864ace5d161d81234b8` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vhdx) | `3a37661ebdfba6dd463fa9e2ce333c017635b4d5b738a419c4dd7ad44461e043` |
| `Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 965M /<br>1010987008 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040943.SGprod-v2026.06.04-0840-2-ga21f77f.x86_64.vmdk) | `20fda710c6bc80ea17534db96d752204e619223fdad58226fe9f8f2c0df74218` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1349 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `6c626ff26be1195039df87c4ed7de6f20bf2abd65116996a3e7f687f5553130d` |

<!-- Script will replace everything BEFORE this line -->
