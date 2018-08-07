/**
 * Demonstration of org level code configured bindings
 **/
public class RuntimeBindingDemoOrg {

    /**
     * This application has two dependencies defined via the Display interface and Message base class
     **/

    /**
     * The application outputs a message to the user
     **/
    public class WelcomeApp {

        // Inject dependences via org level injector
        private Message message = (Message) di_Injector.Org.getInstance(Message.class);
        private Display display = (Display) di_Injector.Org.getInstance(Display.class);

        public String greetings() {
            return display.startup() + ':' + message.saySomething();
        }
    }

    /**
     * This example uses purely runtime binding configuration
     **/
    public static void run() {

        // Run the app!
        WelcomeApp welcomeApp = new WelcomeApp();
        System.debug(welcomeApp.greetings());
    }

    /**
     * This class to configure the bindings is injected into the Injector.Org instance via Binding__mdt
     **/
    public class WelcomeAppBindings extends di_Module {

        /**
         * Org level bindings are also visible to the injector Visualforce and Lightning components
         **/
        public override void configure() {
            // Vary Message and Display implementations depending on the users out of office
            if (UserAvailability__c.getInstance().OutOfOffice__c) {
                bind(Message.class).to(Weekday.class);
                bind(Display.class).to(BeAwesome.class);
            } else {
                bind(Message.class).to(Weekend.class);
                bind(Display.class).to(Fun.class);
            }
        }
    }

    /**
     * The WelcomeApp class is unware of the specific implementations
     **/
    public class Weekday extends Message {
        public override String saySomething() {
            return 'Have a good day at work!';
        }
    }
    public class Weekend extends Message {
        public override String saySomething() {
            return 'Have a great weelend!';
        }
    }
    public class BeAwesome implements Display {
        public String startup() {
            return 'Go be awesome!';
        }
    }
    public class Fun implements Display {
        public String startup() {
            return 'Party time!';
        }
    }
}
