#!/usr/bin/env groovy

// import com.cloudbees.plugins.credentials.*
import hudson.model.*
import hudson.PluginManager.*
// import hudson.scm.*
import hudson.security.*
import jenkins.model.*


class JenkinsUser {
    String username, password, role;
}

class Security {
    Jenkins j = jenkins.model.Jenkins.get();
    HudsonPrivateSecurityRealm realm = j.getSecurityRealm();

    boolean setMatrix(String un, String pw, String ur) {
        boolean flag = false;
        User u = hudson.model.User.getById(un, true);
        u.addProperty(hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword(pw));
        u.save();

        def strategy = j.getAuthorizationStrategy();
        if (!(strategy instanceof GlobalMatrixAuthorizationStrategy)) {
            return flag;
        }

        strategy.add(hudson.model.Hudson.READ, un);
        strategy.add(hudson.model.Item.READ, un);
        strategy.add(hudson.model.View.READ, un);

        if (ur == 'admin') {
// Overall
            strategy.add(hudson.model.Hudson.ADMINISTER, un);
            strategy.add(hudson.model.Hudson.RUN_SCRIPTS, un);
            strategy.add(hudson.PluginManager.CONFIGURE_UPDATECENTER, un);
            strategy.add(hudson.PluginManager.UPLOAD_PLUGINS, un);
// Slave
            // strategy.add(hudson.model.Computer.BUILD, un);
            // strategy.add(hudson.model.Computer.CONFIGURE, un);
            // strategy.add(hudson.model.Computer.CONNECT, un);
            // strategy.add(hudson.model.Computer.CREATE, un);
            // strategy.add(hudson.model.Computer.DELETE, un);
            // strategy.add(hudson.model.Computer.DISCONNECT, un);
// Job
            // strategy.add(hudson.model.Item.BUILD, un);
            // strategy.add(hudson.model.Item.CANCEL, un);
            // strategy.add(hudson.model.Item.CONFIGURE, un);
            // strategy.add(hudson.model.Item.CREATE, un);
            // strategy.add(hudson.model.Item.DELETE, un);
            // strategy.add(hudson.model.Item.DISCOVER, un);
            // strategy.add(hudson.model.Item.WORKSPACE, un);
            //// strategy.add(hudson.model.Item.EXTENDED_READ, un);
            //// strategy.add(hudson.model.Item.WIPEOUT, un);
// Run
            // strategy.add(hudson.model.Run.DELETE, un);
            // strategy.add(hudson.model.Run.UPDATE, un);
            //// strategy.add(hudson.model.Run.ARTIFACTS, un);
// View
            // strategy.add(hudson.model.View.CONFIGURE, un);
            // strategy.add(hudson.model.View.CREATE, un);
            // strategy.add(hudson.model.View.DELETE, un);
// SCM
            // strategy.add(hudson.scm.SCM.TAG, un);
// Credential
            // strategy.add(CredentialsProvider.CREATE, un);
            // strategy.add(CredentialsProvider.DELETE, un);
            // strategy.add(CredentialsProvider.MANAGE_DOMAINS, un);
            // strategy.add(CredentialsProvider.UPDATE, un);
            // strategy.add(CredentialsProvider.VIEW, un);
        } else if (ur == 'developer') {
// Overall
            // strategy.add(hudson.model.Hudson.ADMINISTER, un);
            // strategy.add(hudson.model.Hudson.RUN_SCRIPTS, un);
            // strategy.add(hudson.PluginManager.CONFIGURE_UPDATECENTER, un);
            // strategy.add(hudson.PluginManager.UPLOAD_PLUGINS, un);
// Slave
            // strategy.add(hudson.model.Computer.BUILD, un);
            // strategy.add(hudson.model.Computer.CONFIGURE, un);
            // strategy.add(hudson.model.Computer.CONNECT, un);
            // strategy.add(hudson.model.Computer.CREATE, un);
            // strategy.add(hudson.model.Computer.DELETE, un);
            // strategy.add(hudson.model.Computer.DISCONNECT, un);
// Job
            // strategy.add(hudson.model.Item.BUILD, un);
            // strategy.add(hudson.model.Item.CANCEL, un);
            // strategy.add(hudson.model.Item.CONFIGURE, un);
            // strategy.add(hudson.model.Item.CREATE, un);
            // strategy.add(hudson.model.Item.DELETE, un);
            // strategy.add(hudson.model.Item.DISCOVER, un);
            // strategy.add(hudson.model.Item.WORKSPACE, un);
            //// strategy.add(hudson.model.Item.EXTENDED_READ, un);
            //// strategy.add(hudson.model.Item.WIPEOUT, un);
// Run
            // strategy.add(hudson.model.Run.DELETE, un);
            // strategy.add(hudson.model.Run.UPDATE, un);
            //// strategy.add(hudson.model.Run.ARTIFACTS, un);
// View
            // strategy.add(hudson.model.View.CONFIGURE, un);
            // strategy.add(hudson.model.View.CREATE, un);
            // strategy.add(hudson.model.View.DELETE, un);
// SCM
            // strategy.add(hudson.scm.SCM.TAG, un);
// Credential
            // strategy.add(CredentialsProvider.CREATE, un);
            // strategy.add(CredentialsProvider.DELETE, un);
            // strategy.add(CredentialsProvider.MANAGE_DOMAINS, un);
            // strategy.add(CredentialsProvider.UPDATE, un);
            // strategy.add(CredentialsProvider.VIEW, un);
        }
        flag = true;
        return flag;
    }
}

JenkinsUser user = new JenkinsUser(username: '${user_name}', 
    password: '${user_pass}', 
    role: '${user_role}');
Security security = new Security();

if (security.setMatrix(user.username, user.password, user.role)) {
    println "security was configured";
} else {
    println "security configuration failed";
}