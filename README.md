# Force DI

Generic [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) library with support for injecting Apex, Visualforce, Lightning, and Flows at runtime. 

Documentation
-------------
- [General overview of the library features, configuration and use of Injectors](https://andyinthecloud.com/2018/07/15/managing-dependency-injection-within-salesforce/) (blog)
- [Using the library to aid with Test Driven Development in Apex](https://andyinthecloud.com/2018/07/29/test-driven-development-mocking-and-force-di/) (blog)
- [Dependency Injection, Flows, and Force DI](https://douglascayers.com/2018/08/05/dependency-injection-flows-and-force-di/) (blog)
- [Dependency Injection, Flows, and Force DI](https://www.youtube.com/watch?v=YzaI5Ddfwkg) (webinar)
- [Understanding the Value of Dependency Injection in the Lightning Platform](https://www.youtube.com/watch?v=oce2QO-E_3k) (DF18 session)

Project Folders
---------------
The "core" framework is found in this project.  This includes the following:

| Folder | Description |
| ------ | ----------- |
| **force-di** | Core library, contains **Injector** Apex API and **<c:di_injector>** VF and Lightning Components |

The "samples" of how to use the framework can be found in the [Force-DI Samples](https://github.com/apex-enterprise-patterns/force-di-samples) project.

| Folder | Description |
| ------ | ----------- |
| **force-app-1** | Sample application using the API and Components to inject Apex, VF and Lightning at runtime |
| **force-app-2** | Sample package providing impls for various bindings above |
| **force-app-3** | Sample package providing impls for various bindings above |
| **force-di-trigger-demo** | Sample basic trigger framework leveraging the API |


![Force DI Example](https://andrewfawcett.files.wordpress.com/2018/07/forcedi2.png)


Other Resources on Dependency Injection Design Pattern
------------------------------------------------------

Some of these blogs and videos are not necessarily Salesforce-specific but give good insights on use cases and purpose behind this design pattern.

### Videos

- [Dependency Injection Overview](https://www.youtube.com/watch?v=IKD2-MAkXyQ&t=0s&index=3&list=PL-oxrNbxQl3-wPOf0t3PT-0JYXiOBwReG) by Anthony Ferrara
- [Advanced Apex Design Patterns](https://www.youtube.com/watch?v=BLXp0ZP0cF0) by Andy Fawcett
- [Writing True Unit Tests Using Dependency Injection and Mocking](https://www.youtube.com/watch?v=hj4538vR6Mg&list=PL-oxrNbxQl3-wPOf0t3PT-0JYXiOBwReG&index=4) by Alex Tennant

### Blogs

- [Injection Design Pattern](https://martinfowler.com/articles/injection.html) by Martin Fowler
- [Dependency Injection is not the same as Dependency Inversion](https://lostechies.com/derickbailey/2011/09/22/dependency-injection-is-not-the-same-as-the-dependency-inversion-principle/) by Derick Bailey
- [Dependency Injection](https://stackify.com/dependency-injection) by Thorben Janssen
