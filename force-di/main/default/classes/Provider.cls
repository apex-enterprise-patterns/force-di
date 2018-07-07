/**
 * Allows bindings to resolve dynamically based on params if needed
 **/
public interface Provider {
    Object newInstance(Object params);
}
