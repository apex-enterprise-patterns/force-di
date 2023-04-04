@IsTest
private class di_NamespaceClassTest {

    @IsTest
    private static void testNamespaceClass() {
        // When
        String currentNamespace = di_NamespaceClass.CURRENTNAMESPACE;

        // Then
        Assert.areEqual('di_NamespaceClass', currentNamespace);
    }
}
