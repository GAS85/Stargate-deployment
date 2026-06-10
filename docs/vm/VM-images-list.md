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
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>255 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.mf) | `f812dddcc1b64a6f185d98d76bf7b190dbba0592591086d173b83333237ae2b0` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 957M /<br>1002977280 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.ova) | `ff29f5a195266b94f4b13026c84ff7ae65b6ebfef320f1f712afb530de11b4e5` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7684 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.ovf) | `324558878eb3b0bf866601c5f99b5da003e49b52a53db54e2a48dbda468dbc24` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1638465536 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.qcow2) | `4fa61d37d42118b40c232a74f50352a60a1be758ea0b9813506abb8411821626` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.raw) | `174d102e004560547df2d1da9587a29497239c511cb41b0fa0a6cc20f0663e28` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 945M /<br>990444384 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.raw.gz) | `11e7d80e8c7bf1acd0924ad9b657364ee028099b89d43a83c033824646d118db` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhd) | `9e9b3c1602e89db086668b3399778354e23aade1c3bbb1100f8b4729bf061223` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 949M /<br>994990284 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhd.gz) | `31fceff694e214322cbfe974675f7fcb6bc5917e91959c69e374a5628217229d` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vhdx) | `74047b115a81153be3d3588b4e572844fcb7014579f48c7c3f1eeee677fef734` |
| `Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 957M /<br>1002965504 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101347.SGpreprod-v0.5.0-rc2.x86_64.vmdk) | `899e8ea376a1e7642af5b5526cff0fd70600deef745aa261356e02d690fd39b8` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1209 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `cfa571a9f143368ad990c7769baf0cf8459a06131fa695d42635397a8715d383` |

<!-- Script will replace everything BEFORE this line -->
