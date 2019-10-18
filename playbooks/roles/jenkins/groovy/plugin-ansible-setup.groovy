#!/usr/bin/env groovy

package org.jenkinsci.plugins.ansible;

// import com.dabsquared.gitlabjenkins.connection.*;

// import hudson.model.*;
import jenkins.model.*;

class AnsiblePlugin {
    boolean setupAnsible() {
        Jenkins j = jenkins.model.Jenkins.get();

// // https://javadoc.jenkins.io/plugin/ansible/org/jenkinsci/plugins/ansible/AnsibleInstallation.html
        Descriptor desc = j.getDescriptor("AnsibleInstallation");

// // https://javadoc.jenkins.io/hudson/tools/ToolInstallation.html
        def ainst =  new org.jenkinsci.plugins.ansible.AnsibleInstallation("ansible 2.4.2.0", "/usr/bin/", []);

// // https://javadoc.jenkins.io/hudson/tools/ToolDescriptor.html
        desc.setInstallations(ainst);
        desc.save();

        return true
    }
}

AnsiblePlugin anspl = new AnsiblePlugin();

if (anspl.setupAnsible()) {
    println "ansible plugin set";
} else {
    println "ansible plugin setup failed";
}