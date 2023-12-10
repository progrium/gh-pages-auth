# gh-pages-auth
Auth0 and GitHub Pages bootstrapper for self-modifying sites

## Overview
After registering and pointing a domain to GitHub, you can just fork this repository to your account using the domain as the repository name, set some variables in the repository settings, and run a GitHub Action that will set everything else up.

You'll then have a static site on your domain with a simple JavaScript API to login, logout, check if authenticated, and get the current user, which if is your GitHub user will include a GitHub API token with read-write access to your repositories. All without paid plans.

Because you login with GitHub initially and we set this up to include the GitHub API token for your user, you can use this as a foundation for a static site that modifies itself.

## Getting Started
* **Register a domain** and point DNS to GitHub
  * Create root/apex record
    * Create `ALIAS` record if possible to `<username>.github.io`
    * Or create an `A` record to `185.199.108.153` (GitHub IPs)
  * Also create a `www` subdomain record so GitHub Pages is happy
* [Create a free Auth0 account](https://auth0.com/signup) and tenant
* **Set up and get Auth0 credentials** for the `Default App` in your tenant:
  * Change it to `Machine to Machine`:
    * On the Dashboard under Applications in the sidebar, select Applications
    * Click on the `Default App` application
    * Set "Application Type" to `Machine to Machine` under Application Properties
    * Scroll down and click Save Changes
  * Grant all permissions for Auth0 Management API:
    * Go to "APIs" tab for `Default App`
    * Toggle to enable authorization for "Auth0 Management API"
    * Expand this section to show permissions and click Select All
    * Click Update and confirm with Continue
  * Get credentials to paste in later on
    * Go back to Settings for `Default App`
    * Copy and store these fields under Basic Information:
      * Domain
      * Client ID
      * Client Secret
* **Create an OAuth App** on your GitHub account for your site:
  * Go to your [account settings](https://github.com/settings/profile) and go to Developer Settings.
  * Under OAuth Apps, create a new OAuth App. This will show when you Login with GitHub.
  * Name and Homepage URL are up to you, but should represent your new website.
  * Using the Auth0 tenant domain, set Authorization callback URL to:
    * `https://{AUTH0_DOMAIN}/login/callback`
  * Copy and store the Client ID
  * Generate, copy, and store a Client Secret
* **Fork this repository**, using your domain as the new repository name
* Go into `Settings > Secrets and variables > Actions` and **create these Repository Secrets** using fields from before:
  * GH_CLIENT_ID => your GitHub OAuth app Client ID
  * GH_CLIENT_SECRET => your GitHub OAuth app Client Secret
  * AUTH0_DOMAIN => your Auth0 tenant domain
  * AUTH0_CLIENT_ID => your Auth0 Default App Client ID
  * AUTH0_CLIENT_SECRET => your Auth0 Default App Client Secret
  * SITE_ADMIN => your GitHub username
* Go to `Actions` and enable workflows. Then go to `pages-auth-setup` and **run the workflow** on the main branch. This is automated, but will:
  * Create and configure an Auth0 app for your domain
  * Enable GitHub logins
  * Create an Auth0 Action on login to only allow your user and to include the GitHub API token in your userdata
  * Reset Management API permissions on Default App to just the few that are needed from here on
* Go to `Settings > Pages` and **select the `public` branch** to deploy from and hit Save. It will provision TLS and check DNS for the custom domain (which you don't have to set) and may complain unless you also set up a `www` subdomain, but should be fine without. 
* Lastly, be sure to **check "Enforce HTTPS"** when TLS setup has finished. You may have to manually refresh the page for this to become available.

You can now go to your domain and a placeholdler `index.html` will let you login, see your logged in user, and logout. 

## Auth module
You can modify your site however you like, but leave the `auth` directory as is. This is your "auth module" that handles login flows with Auth0 and contains the JavaScript ES module `/auth/api.js` that you can import and use to interact with authentication. It exposes this API as exported functions:

* `login(redirect?: string)` - This will redirect the user to authenticate and use the optional `redirect` param to redirect back to. It defaults to `/`.
* `logout(redirect?: string)` - This will redirect the user to clear authentication and use the optional `redirect` param to redirect back to. It defaults to `/`.
* `isAuthenticated(): boolean` - Whether or not the user has authenticated.
* `currentUser(): Object|null` - If authenticated, it will return an object with user information. If not authenticated, it returns `null`. If this user is the SITE_ADMIN it will contain a GitHub API access token with `repo` and `profile` scope.
* `accessToken(): string|null` - If authenticated, it will return the Auth0 access token JWT. If not authenticated, it returns `null`.

This auth module and API store user profile and access token state using `localStorage` so this API is useable from any page on this domain. Keep that in mind especially if you work with and allow third-party scripts on your site.

## Auth0 customization

You can further customize your authentication system from the Auth0 dashboard. For example, you can enable other authentication methods, including username and password. You can also manage users, but to allow more than you to login, you'll have to edit the `on-login` Action being used in the Login flow. 

## Main branch

You can edit your GitHub Pages `public` branch as usual to deploy updates, but you can also now replace the `main` branch with anything you like. This also goes for the setup workflow files under `.github` which are now unnecessary. 
