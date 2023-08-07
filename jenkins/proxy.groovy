import hudson.security.csrf.DefaultCrumbIssuer
import import hudson.model.*

def instance = Jenkins.instance
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()
