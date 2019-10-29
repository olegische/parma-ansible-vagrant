#!/usr/bin/env groovy

import hudson.model.*;
import jenkins.model.*;

// import hudson.plugins.*;

import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*;

class JenkinsCredentials {
    Jenkins j = jenkins.model.Jenkins.get();
// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/domains/Domain.html
    def domain = com.cloudbees.plugins.credentials.domains.Domain.global();
// https://javadoc.jenkins.io/hudson/ExtensionList.html
    ExtensionList exlist = j.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider');
// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/CredentialsProvider.html
// https://javadoc.jenkins.io/plugin/credentials/com/cloudbees/plugins/credentials/CredentialsStore.html
    CredentialsStore credStore = exlist[0].getStore();

    boolean sshCredentials(String un, String kf) {
        boolean flag = false;
// https://javadoc.jenkins.io/plugin/ssh-credentials/com/cloudbees/jenkins/plugins/sshcredentials/impl/BasicSSHUserPrivateKey.html
        BasicSSHUserPrivateKey​ privateKey = new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey(
            CredentialsScope.GLOBAL,
            un + "_ssh_key",
            un,
            new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(kf), // deprecated
            "",
            ""
        );
        credStore.addCredentials(domain, privateKey);
        println "ssh credential created";
    }
}

JenkinsCredentials credential = new JenkinsCredentials();
switch('${credential_type}') {
    case ssh:
        credential.sshCredentials('${username}', '${key_file}');
        break;
    default:
        println "credential type does't set";
        break;
}