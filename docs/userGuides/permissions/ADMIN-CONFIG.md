# Administrator Configuration
[![Project Version][version-image]][version-url]

---

1. Call the addAppAdministrator function on the AppManager. It accepts one parameter, address of the desired appAdministrtor, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
   ````
   cast send 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575 "addAppAdministrator(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ````

2. Repeat for all admin accounts. Admins may be added at any time.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron