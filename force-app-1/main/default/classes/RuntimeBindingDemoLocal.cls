/**
 * Demonstration of local code configured bindings
 **/
public class RuntimeBindingDemoLocal {

    /**
     * This application has two dependencies defined as follows
     **/
    public interface Display {
        String say(Message message);
    }
    public abstract class Message {
        public abstract String saySomething();
    }

    /**
     * The application outputs a message to the user
     **/
    public class WelcomeApp {

        private Message message;        
        private Display display;

        public WelcomeApp(Injector injector) {

            // Inject dependences based on the given injector
            message = (Message) injector.getInstance(Message.class);
            display = (Display) injector.getInstance(Display.class);
        }

        public String greetings() {
            return display.say(message);
        }
    }

    /**
     * This example uses purely runtime binding configuration
     **/
    public static void run() {

        // Configure the apps dependencies
        Injector injector = configureBindings();

        // Run the app!
        WelcomeApp welcomeApp = new WelcomeApp(injector);
        System.debug(welcomeApp.greetings());
    }

    /**
     * The applications dependencies are configured dynamically via the above Injector
     **/
    public static Injector configureBindings() {

        // Vary Message and Display implementations depending on the users out of office
        return
            new Injector(
                UserAvailability__c.getInstance().OutOfOffice__c ?
                    new Module()
                        .bind(Message.class).to(Weekday.class)
                        .bind(Display.class).to(BeAwesome.class) :
                    new Module()
                        .bind(Message.class).to(Weekend.class)
                        .bind(Display.class).to(Fun.class));
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
        public String say(Message message) {
            return 'Go be awesome! ' + message.saySomething();
        }
    }    
    public class Fun implements Display {
        public String say(Message message) {
            return 'Party time! ' + message.saySomething();
        }
    }
}
