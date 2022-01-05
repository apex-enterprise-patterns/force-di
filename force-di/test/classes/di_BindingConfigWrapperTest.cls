/**
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/
/**
 * Modifications:
 * =============
 *  B Anderson : Gettting the overall code-coverage > 75%
 */ 
@isTest
private with sharing class di_BindingConfigWrapperTest {

    @isTest
    static void givenBindingWrapperThenExtractAndValidate(){
        // Given
        di_BindingConfigWrapper wrapper = new di_BindingConfigWrapper(
            'QualifiedAPIName'
            , 'DeveloperName'
            , 'NamespacePrefix'
            , 'Type'
            , 'To'
            , 'BindingObject'
            , 'BindingObjectQualifiedApiName'
            , 'BindingObjectAlternate'
            , 10.10
            );
        // Then
        system.assertEquals('QualifiedAPIName', wrapper.QualifiedAPIName);
        system.assertEquals('DeveloperName',  wrapper.DeveloperName);
        system.assertEquals('NamespacePrefix', wrapper.NamespacePrefix);
        system.assertEquals('Type', wrapper.Type);
        system.assertEquals('To', wrapper.To);
        system.assertEquals('BindingObject', wrapper.BindingObject);
        system.assertEquals('BindingObjectQualifiedApiName', wrapper.BindingObjectQualifiedApiName);
        system.assertEquals('BindingObjectAlternate', wrapper.BindingObjectAlternate);
        system.assertEquals(10.10, wrapper.BindingSequence);
    }

    @isTest
    static void givenBindingWrapperWithMDTThenExtractAndValidate(){
        // Given
        di_Binding__mdt bindingConfig = new di_Binding__mdt();
        bindingConfig.QualifiedApiName='QualifiedAPIName';
        bindingConfig.DeveloperName='DeveloperName';
        bindingConfig.NamespacePrefix='NamespacePrefix';
        bindingConfig.Type__c='Type';
        bindingConfig.To__c='To';
        bindingConfig.BindingObject__c='BindingObject';
        bindingConfig.BindingObjectAlternate__c='BindingObjectAlternate';
        bindingConfig.BindingSequence__c=10.10;
        di_BindingConfigWrapper wrapper = new di_BindingConfigWrapper(bindingConfig);
        // Then
        system.assertEquals('QualifiedAPIName', wrapper.QualifiedAPIName);
        system.assertEquals('DeveloperName',  wrapper.DeveloperName);
        system.assertEquals('NamespacePrefix', wrapper.NamespacePrefix);
        system.assertEquals('Type', wrapper.Type);
        system.assertEquals('To', wrapper.To);
        system.assertEquals('BindingObject', wrapper.BindingObject);
        system.assertEquals('BindingObjectAlternate', wrapper.BindingObjectAlternate);
        system.assertEquals(10.10, wrapper.BindingSequence);
    }

    @isTest
    static void givenBindingWrapperWithBindingNameExpectDeveloperNameEqualsBindingName(){
        // Given
        di_Binding__mdt bindingConfig = new di_Binding__mdt();
        bindingConfig.QualifiedApiName='QualifiedAPIName';
        bindingConfig.DeveloperName='DeveloperName';
        bindingConfig.BindingName__c='BindingName';
        bindingConfig.NamespacePrefix='NamespacePrefix';
        bindingConfig.Type__c='Type';
        bindingConfig.To__c='To';
        bindingConfig.BindingObject__c='BindingObject';
        bindingConfig.BindingObjectAlternate__c='BindingObjectAlternate';
        bindingConfig.BindingSequence__c=10.10;

        //when
        di_BindingConfigWrapper wrapper = new di_BindingConfigWrapper(bindingConfig);

        // Then
        system.assertEquals('QualifiedAPIName', wrapper.QualifiedAPIName, 'Expecting specific value of wrapper QualifiedAPIName');
        system.assertEquals('BindingName',  wrapper.DeveloperName, 'Expecting Developer name equals Binding Name');
        system.assertEquals('NamespacePrefix', wrapper.NamespacePrefix, 'Expecting specific value of wrapper NamespacePrefix');
        system.assertEquals('Type', wrapper.Type, 'Expecting specific value of wrapper Type');
        system.assertEquals('To', wrapper.To, 'Expecting specific value of wrapper To');
        system.assertEquals('BindingObject', wrapper.BindingObject, 'Expecting specific value of wrapper BindingObject');
        system.assertEquals('BindingObjectAlternate', wrapper.BindingObjectAlternate, 'Expecting specific value of wrapper BindingObjectAlternate');
        system.assertEquals(10.10, wrapper.BindingSequence, 'Expecting specific value of wrapper BindingSequence');
    }
}
