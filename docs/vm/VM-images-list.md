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
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 992M /<br>1040117760 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.ova) | `3066876c4b64b79e916216429ec9d8e3bdf2f7ada41556d83ff85b5efbb4286a` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>251 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.mf) | `63faeae8aaaaf3ec6d1b52ae9c17866feeca2ca5d6ea621fa9cd56880dd8a0d3` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7682 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.ovf) | `5ce3bd98cbe58c65bedd9f5d02d71aa80476901dfba301aeec4666b8d1046c26` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1677000704 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.qcow2) | `023600c6b274fb944f83e7fce10485896aad0d859d613723d458ac5d4fee649f` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.raw) | `77f4219cc73a23d54d65abacf836ee3fa7d275ca929cb226b7065d52f33bf2d6` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1000M /<br>1048112496 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.raw.gz) | `0c428e670de72095b2e7f20b23cc42e4a614a0dccc1db3d8bf908b6408510a73` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhd) | `95512ee2332a3e5b8bb172777520f8e2d2014ed91f24286ac2e7f0affc195914` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1008M /<br>1056473561 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhd.gz) | `004a1aec15b8f0462882c5dcf9b2bfcd6154d3d339a5e212fa3cdd411fbbd447` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.2G /<br>2256535552 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vhdx) | `4cbeba397c9d175a508ef3d73ebf0977b3e8e4643889634fd8e1881d07f4772b` |
| `Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 992M /<br>1040103424 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606190913.SGprod-v0.5.0-rc13.x86_64.vmdk) | `db8c20bccd35b85290ab1d83afeeb6ba3b02ebf03c0aed63cb6c4598775961c8` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1189 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `0bee2f4e49e07ee3664f38f0e20c1baab12a92bcc35657211074a2756d78c530` |

<!-- Script will replace everything BEFORE this line -->
