#!/usr/bin/env groovy

// package org.jenkinsci.plugins.ansible;

// import com.dabsquared.gitlabjenkins.connection.*;

import hudson.model.*;
import jenkins.model.*;

// import hudson.plugins.*;

import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.impl.*;



String gitlabUserName = 'devel';
String gitlabUserPass = 'devel';


Jenkins j = jenkins.model.Jenkins.get();

// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/domains/Domain.html
def domain = com.cloudbees.plugins.credentials.domains.Domain.global();

// https://javadoc.jenkins.io/hudson/ExtensionList.html
ExtensionList exlist = j.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider');

// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/CredentialsProvider.html
// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/CredentialsStore.html
CredentialsStore credStore = exlist[0].getStore();

// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/impl/UsernamePasswordCredentialsImpl.html
// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/CredentialsScope.html
UsernamePasswordCredentialsImpl gitlabAccount = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL, "vm-gitlab", "Test GitLab Account",
        gitlabUserName,
        gitlabUserPass
);
credStore.addCredentials(domain, gitlabAccount);

// !!! add privae key for jenkins to connect ssh vm-testbox jenkins user





// // https://javadoc.jenkins.io/plugin/ansible/org/jenkinsci/plugins/ansible/AnsibleInstallation.html
// Descriptor desc = j.getDescriptor("AnsibleInstallation");

// // https://javadoc.jenkins.io/hudson/tools/ToolInstallation.html
// def ainst =  new org.jenkinsci.plugins.ansible.AnsibleInstallation("ansible 2.4.2.0", "/usr/bin/", []);

// // https://javadoc.jenkins.io/hudson/tools/ToolDescriptor.html
// desc.setInstallations(ainst);
// desc.save();

// import com.dabsquared.gitlabjenkins.connection.*
// import jenkins.model.Jenkins

// // https://javadoc.jenkins.io/plugin/gitlab-plugin/com/dabsquared/gitlabjenkins/connection/GitLabConnection.html
// GitLabConnectionConfig descriptor = (GitLabConnectionConfig) Jenkins.getInstance().getDescriptor(GitLabConnectionConfig.class)

// GitLabConnection gitLabConnection = new GitLabConnection('MyGitLab',
//                                         'https:\\\\gitlaburl.com',
//                                         'GitLabTokenId',
//                                         false,
//                                         10,
//                                         10)
// descriptor.getConnections().clear()
// descriptor.addConnection(gitLabConnection)
// descriptor.save()


// Class cl = inst.getClass();

// println(cl);
// println(cl.getDeclaredFields());
// println(cl.getDeclaredMethods());

// for (def field : cl.getDeclaredFields()) {
//     try {
//     	Object value = field.get(inst);
//     	if ( value ) {
//         	println(field.getName() + " = " + value);
//         }
//     } catch (Exception error) {
//         error.printStackTrace();
//     }
// }

// for (def method : cl.getDeclaredMethods()) {
//     try {
//         println(method.getName() + " "
//         	// + " ");
//         	// + method.getModifiers() + " "
//         	+ method.getReturnType() + " "
//         	+ method.getParameterTypes());
//     } catch (Exception error) {
//         error.printStackTrace();
//     }
// }

// println('tested');


// i7af7nYKafYXBgo5mIWnaWSuGHEjWhz0FmKq1mX2BsPbeu0hn/sJWbjObJ4lAEqR
// 987request
// cJ8mHfTG1zFOvEpHUhFZXIg2jF0CbxzkXSysAfQogNl45MaLXj3GzDvMwJ9yzp

//// Research steps
// println(jenkins.getAuthorizationStrategy().getClass().getDeclaredFields());
// println(jenkins.getAuthorizationStrategy().grantedPermissions.collect { permission, userList -> return userList });

// method.getModifiers() // The modifiers consist of the Java Virtual Machine's constants for public, protected, private, final, static, abstract and interface

// Class cl = inst.getSecurityRealm().getClass();
// // println(cl.getDeclaredFields());
// // println(cl.getDeclaredMethods());

// for (def field : cl.getDeclaredFields()) {
//     try {
//     	Object value = field.get(inst);
//     	if ( value ) {
//         	println(field.getName() + " = " + value);
//         }
//     } catch (Exception error) {
//         error.printStackTrace();
//     }
// }

// for (def method : cl.getDeclaredMethods()) {
//     try {
//         println(method.getName() + " "
//         	// + method.getModifiers() + " "
//         	+ method.getReturnType() + " "
//         	+ method.getParameterTypes());
//     } catch (Exception error) {
//         error.printStackTrace();
//     }
// }

// j.pluginManager.plugins.each { plugin -> println(plugin.getDisplayName()+" --> "+plugin.getShortName()+": "+plugin.getVersion()+"####") };

// println(jenkins.getAuthorizationStrategy().grantedPermissions.collect { permission, users -> 
// 	return users.collect { user -> 
// 		return [ (user) : (permission).id.tokenize('.')[-2..-1] ] } });