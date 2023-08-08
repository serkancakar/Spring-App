import hudson.security.csrf.DefaultCrumbIssuer
import hudson.model.*
import jenkins.model.*

def instance = Jenkins.instance
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()