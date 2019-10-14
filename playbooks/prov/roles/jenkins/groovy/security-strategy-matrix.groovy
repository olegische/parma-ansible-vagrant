#!/usr/bin/env groovy

// import com.cloudbees.plugins.credentials.*
import hudson.model.*
// import hudson.PluginManager.*
// import hudson.scm.*
import hudson.security.*
import jenkins.model.*


class User {
    String username;
}

class Security {
    HudsonPrivateSecurityRealm realm = new HudsonPrivateSecurityRealm(false);

    void setMatrix(String un) {
        Jenkins j = Jenkins.get();
        j.setSecurityRealm(realm);

        GlobalMatrixAuthorizationStrategy strategy = new GlobalMatrixAuthorizationStrategy();
// Overall
        strategy.add(hudson.model.Hudson.ADMINISTER, un);
        strategy.add(hudson.model.Hudson.READ, un);
// Job
        strategy.add(hudson.model.Item.READ, un);
        strategy.add(hudson.model.View.READ, un);

        j.setAuthorizationStrategy(strategy);
        j.save();
        println "matrix security set";
    }
}

User user = new User(username: '${admin_name}');
Security security = new Security();
security.setMatrix(user.username);