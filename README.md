# kidfriendly

## Setup instructions

### Server

Run local server
```bash
TODO: add instructions
```

### Client

#### Website
Run website locally.
```bash
cd /kidfriendly/client/web
npm install
bower install
grunt server
```
#### Mobile
Compile ionic app
```bash
cd /kidfriendly/client/mobile
npm install
bower install
gulp watch  #Sets config to production. All api calls to to kidfriendlyreviews.com/api

#To have app hit localhost for api calls use
gulp watch --env=local-dev
```

To run ionic app in the browser 
```bash
ionic serve
```

To run ionic app in iOS simulator
```bash
ionic platform add ios  #only need to add platform first time
ionic run ios
```

To run ionic app on android device. Requires android sdk and platform tools be installed
http://developer.android.com/sdk/index.html
set ANDROID_HOME in your path.
Plug android device into usb port.
```bash
ionic platform add android  #only need to add platform first time
ionic run android
```

### Ghost
Restart ghost and website all at once
```bash
send forever restart
```

Adding new themes

coming soon!
