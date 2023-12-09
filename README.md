# gh-pages-auth
Setup GitHub Pages with Auth0 authentication

## Overview
With a little bit of manual setup, including registering and pointing a domain to GitHub, you can just fork this repository to your account using the domain as the repository name, set some variables in the repository settings, and run a GitHub Action that will set everything else up.

You'll then have a static site on your domain with a simple JavaScript API to login, logout, check if authenticated, and get the current user, which if is your GitHub user will include a GitHub API token with access to the repository. 

You can then configure Auth0 to allow other forms of login, allow and manage other users, and build a static JavaScript site/app with this authentication.

## Getting Started
* Register a domain and point DNS to GitHub
  * Create root/apex record
    * Create `ALIAS` record if possible to `<username>.github.io`
    * Or create an `A` record to `185.199.108.153` (GitHub IPs)
  * Also create a record for `www` subdomain, just so GitHub Pages is happy
* Create a free Auth0 account and tenant
* Set up and get credentials for the `Default App` in your Auth0 tenant:
  * Change it to `Machine to Machine`:
    * On the Dashboard under Applications in the sidebar, select Applications
    * Click on the `Default App` application
    * Set "Application Type" to `Machine to Machine` under Application Properties
  * Grant all permissions for Auth0 Management API:
    * Go to "APIs" tab for `Default App`
    * Expand the section for "Auth0 Management API"
    * Click link to Select All
    * Click Update and confirm with Continue
  * Get credentials to paste in later on
    * Go back to Settings for `Default App`
    * Copy and store these fields under Basic Information:
      * Domain
      * Client ID
      * Client Secret
* Create an OAuth App on your GitHub account for your site:
  * TODO
  * Copy and store these fields:
    * Client ID
    * Client Secret
* Fork this repository, using your domain as the new repository name
* Go into `Settings > Secrets and variables > Actions` and create these Repository Secrets using fields from before:
  * GH_CLIENT_ID => your GitHub OAuth app Client ID
  * GH_CLIENT_SECRET => your GitHub OAuth app Client Secret
  * AUTH0_DOMAIN => your Auth0 tenant domain
  * AUTH0_CLIENT_ID => your Auth0 Default App Client ID
  * AUTH0_CLIENT_SECRET => your Auth0 Default App Client Secret
  * SITE_ADMIN => your GitHub username
* Go to `Actions > pages-auth-setup` and run the workflow. This is automated, but will:
  * Create and configure an Auth0 app for your domain
  * Enable GitHub logins
  * Create an Auth0 Action on login to only allow your user and to include the GitHub API token in your userdata
  * Reset Management API permissions on Default App to just the few that are needed from here on
* Lastly, go to `Settings > Pages` and select the `public` branch to deploy from and hit Save. It will check DNS for the custom domain (which you don't have to set) and may complain unless you also set up a `www` subdomain, but should be fine without. Be sure to check "Enforce HTTPS" when you can.