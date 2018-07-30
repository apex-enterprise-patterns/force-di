# Force DI

Generic [DI](https://en.wikipedia.org/wiki/Dependency_injection) library with support for injecting Apex, Visualforce and Lightning code at runtime. 

Documentaiton
-------------
- [General overview of the library features, configuration and use of Injectors](https://andyinthecloud.com/2018/07/15/managing-dependency-injection-within-salesforce/)
- [Using the library to aid with Test Driven Development in Apex](https://andyinthecloud.com/2018/07/29/test-driven-development-mocking-and-force-di/)

Project Folders
---------------

![Force DI Example](https://andrewfawcett.files.wordpress.com/2018/07/forcedi2.png)

| Folder | Description |
| ------ | ----------- |
| **force-di** | Core library, contains **Injector** Apex API and **<c:injector>** VF and Lightning Components |
| **force-app-1** | Sample application using the API and Components to inject Apex, VF and Lightning at runtime |
| **force-app-2** | Sample package providing impls for various bindings above |
| **force-app-3** | Sample package providing impls for various bindings above |
| **force-di-trigger-demo** | Sample basic trigger framework leveraging the API |
