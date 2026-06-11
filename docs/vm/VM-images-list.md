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
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>265 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.mf) | `e66469c3eda1efcd9cdfe3f544a3b3852b6b83507e663627865d036b63fa8402` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 930M /<br>974274560 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.ova) | `3f03de1a45aa2bb43b0f59f1896f0ee964ae832e9c8824c7804574e35514e6cc` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7689 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.ovf) | `946654d78ce2281ee6362e04b048aa6ba1c5a0c5ec3f9e5e77dab606eaf62f7e` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.5G /<br>1603534848 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.qcow2) | `6341b51b877882a5a7bbf20c56d992f5c594733dd49a7cad53615be6461e49f4` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.raw) | `74abc39af1bb7010831c7050b7504a5675893333cc6a85051efccd7089a4df8f` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 938M /<br>982746517 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.raw.gz) | `008ed124d4f7abebdd4cebd22341f39b94f0da0aa0fd221c8f3a2dedf11a1382` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhd) | `4adde471a5a74bcc344a61dfa723096acee8719b9c1a2ce81f749b33c0081e3f` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 947M /<br>992919151 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhd.gz) | `e36b0faff43036f7b61c8a9be0a175b81b5f7a84fdbe11e6e62ab6fb12026e11` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.1G /<br>2206203904 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vhdx) | `e6ce36c19145b22cfa5401729e6fe68781ea2619f2d238fe192ac03d20af514b` |
| `Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 930M /<br>974256128 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606112201.SGpreprod-v0.5.0-30G-test.x86_64.vmdk) | `79731c52dfccc6df1acfef5bbed98fca4b173c2ce0759c3efd588d8162c04513` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1259 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `cbfaa3a01e666622cae3a75592dc574b0a19af3eee9f57935aa7a8a31741ef92` |

<!-- Script will replace everything BEFORE this line -->
