/* --------------------------------------------------
|                    Main Configuration
|---------------------------------------------------
|
| Main configuration of the Inbenta application.
|
*/

// Inbenta application configuration
var inbApp = {
  sdkIntegration: {
    version: '1.35.1',
    integrity: 'sha384-PkNbALH+ZMxHDObL8zm8KtSxJErMU8/wR0ggViHb5N1351U29MPCU10pCJZ0m4PM'
                //OLD integrity: 'sha384-v43DDdZosDQxoBvHHMt8dvwhUadkFf4l0ADCihanc94KeTxrhseIygYYWaiQYjzV'
  },
  sdkAuth: {
    //DEVELOPMENT
    publicKey: 'BY3wKsq3W6JA29Q3njcMzRmBWIX1ZMyjrM5uJv/3Njs=',
    domainKey: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwcm9qZWN0IjoibWluZGJvZHlfc2VhcmNoX2VuIiwiZG9tYWluX2tleV9pZCI6IkJhQVJ3QjF2OFlpSU1Ud2h3N1ZDRnc6OiJ9.kXu3fd3-EvcHwz6JLTedz_7lm5r5PnGZMNfUDtOiq9fdcHXVjdu8aZl8xyg4zqz4aJWuW5p_LKH5RBQdMH0FkQ'
    //PRODUCTION
    //publicKey: 'Lp9VigDsIP8a7hUEzYcyoN19wIfyGYsNlyKMsYUSjdU=',
    //domainKey: 'eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJwcm9qZWN0IjoibWluZGJvZHlfc2VhcmNoX2VuIiwiZG9tYWluX2tleV9pZCI6IkJYcDVjekpIcTVETkRHTFQtLUZMNGc6OiJ9.f9R886-SMLjb2LjOXcOsFUJ3r79lzf1pEDUm8d7XqiP3u6O23qqJdVER5TV5XT_XED8B2XBU4QUlPGQ6OzDwwg'
  },
  // Inbenta standard SDK configuration - Check inbenta API/SDK documentation <https://apidocs.inbenta.io/> for more information
  sdkConfig: {
    //environment: 'production',
    environment: 'development', // Required. String. Environments => 'development' / 'preproduction' / 'production'
    userType: 0, // Required. Integer. Select here the wanted profile.
    labels: {
      INSTANTS_HEADER_TEXT: "Related Articles",
      LAST_CHANCE_HEADER_TEXT: "Do these articles answer your question?",
      LAST_CHANCE_CANCEL_BUTTON: "Close",
      LAST_CHANCE_SUBMIT_BUTTON: "No, I want to continue"
    }
  },
  // Inbenta custom application configuration
  appConfig: {
    // Autocompleter Funcionalities
    autocompleter: [
      // Autocompleter Functionality definition
      {
        name: 'main-autocompleter', // Optional. String. Used to create custom clases.
        active: true, // Optional. Boolean.
        // List of Salesforce Community page HTML elements which are required for the Functionality to work.
        elements: {
          textField: 'input.search-field', // Required. String. CSS selector.
          reference: '.search-wrapper', // Optional. String. CSS selector.
          searchButton: ".banner .search-wrapper .search-button"
        },
        // List of SDK's Components required for the Functionality in order to work
        components: {
          results: { // Required. Object. Results Component.
            conf: {}
          },
          autocompleter: { // Required. Object. Autocompleter Component.
            conf: {}
          }
        }
      }
    ],
    // Search Funcionalities
    search: [
      // Search Functionality definition
      {
        //name: 'main-search', // Optional. String. Used to create custom clases.
        active: true, // Optional. Boolean.
       // page: ['*/s/global-search', '*/s/search'], // Optional. String or Array of Strings. URL Path.
        queryFromPath: true, // Optional. Boolean.
        // List of Salesforce Community page HTML elements which are required for the Functionality to work.
        elements: {
          //Required. String. CSS Selector. HTML element where the Search Functionality structure will be placed. 
          //All the content of this element will be overwritten.
          container: '.forceCommunitySearch' // Required. String. CSS selector. //original value
          //container: '.forceCommunityGlobalSearchInput'
        },
        // List of SDK's Components required for the Functionality in order to work
        components: {
          //Can't be disabled.
          results: { // Required. Object. Results Component.
            conf: {}
          },
          searchBox: { // Optional. Object. Search Box Component.
            active: false, // Optional. Boolean.
            conf: {}
          },
          loader: { // Optional. Object. Loader Component.
            active: true, // Optional. Boolean.
            conf: {}
          },      
          noResults: { // Optional. Object. No Results Component.
            active: true, // Optional. Boolean.
            conf: {}
          },
          paginationTop: { // Optional. Object. Pagination Component.
            active: false, // Optional. Boolean.
            conf: {
              padding: 1 // pages before and after the current
            }
          },
          paginationBottom: { // Optional. Object. Pagination Component.
            active: true, // Optional. Boolean.
            conf: {
              padding: 1
            }
          },
          filters: { // Optional. Object. Refinement List Component.
            active: true, // Optional. Boolean.
            conf: {
              refinements: [
                {
                  //attributeName: 'FEED'     //original value
                  attributeName: 'TAGS'
                }
              ]
            }
          },
          tabs: { // Optional. Object. Refinement Tabs Component.
            active: true, // Optional. Boolean.
            conf: {
              //attributeName: 'TOPIC'      //original value
              attributeName: 'SOURCES'
            }
          },
          resultsPerPageSelector: { // Optional. Object. Results Per Page Selector Component.
            active: true, // Optional. Boolean.
            conf: {}
          },
          stats: { // Optional. Object. Stats Component.
            active: true, // Optional. Boolean.
            conf: {}
          },
          sortBy: { // Optional. Object. Sort By Component.
            active: true, // Optional. Boolean.
            conf: {
              attributes: [
                { name: 'desc(_relevance)', label: 'Relevance' },
                { name: 'desc(Source)', label: 'Source - Descending' },
                { name: 'asc(Source)', label: 'Source - Ascending' }
              ]
            }
          }
        }
      }
    ],
    // Deflection Funcionalities
    deflection: [
      // Deflection Functionality definition
      {
        name: 'contactSupport', // Optional. String. Used to create custom clases.
        active: true, // Optional. Boolean.
        page: '*/s/contactsupport', // Optional. String or Array of Strings. URL Path.
        // List of Salesforce Community page HTML elements which are required for the Functionality to work.
       // DEFAULT ELEMENTS COMPONENT PROVIDED BY INBENTA
       /*
        elements: {
          textFields: ['.forceCommunityContactSupportForm .case-subject', '.forceCommunityContactSupportForm .case-description'], // Required. Array of Strings. CSS selectors.
          button: '.forceCommunityContactSupportForm button.contactSupportButton', // Required. String. CSS selector.
          instantsFixedToElement: '.forceCommunityCaseDeflection' // Optional. String. CSS selector.
        },
        */
       elements: {
          //textFields: ['.webForm .caseSubject', '.webForm .caseDescription'],
          textFields: '.inbenta-input',
          button: '.uiButton',
          instantsFixedToElement: '.inbentaRelatedArticles'
       },
        // List of SDK's Components required for the Functionality in order to work
        components: {
          instants: { // Optional. Object. Instants Component.
            active: true, // Optional. Boolean.
            conf: {
              results: {
                resultsPerPage: 5,
                attributes: []
              },
              modifiers: {
                flip: {
                  behavior: ['right', 'bottom-end']
                },
                preventOverflow: {
                  enabled: true,
                  priority: ['right', 'left'],
                  padding: 0,
                  boundariesElement: 'viewport'
                },
                hide: {
                  enabled: true
                }
              }
            }
          },
          lastChance: { // Optional. Object. Last Chances Component.
            active: true, // Optional. Boolean.
            conf: {
              results: {
                resultsPerPage: 5,
                attributes: []
              }
            }
          }
        }
      },
      /*
      // Deflection Functionality definition
      {
        name: 'askQuestion', // Optional. String. Used to create custom clases.
        active: true, // Optional. Boolean.
        page: '*//*(delete the /* to the left)/s/', // Optional. String or Array of Strings. URL Path.
        // List of Salesforce Community page HTML elements which are required for the Functionality to work.
        elements: {
          textFields: ['.forceChatterQuestionPost .cuf-questionTitleField'], // Required. Array of String. CSS selectors.
          button: '.cuf-publisherShareButton[type="button"]', // Required. String. CSS selector.
          instantsFixedToElement: '.forceChatterQuestionPost .forceCommunityCaseDeflection' // Required. String. CSS selector.
        },
        // List of SDK's Components required for the Functionality in order to work.
        components: {
          instants: { // Optional. Object. Instants Component.
            active: true, // Optional. Boolean.
            conf: {
              modifiers: {
                flip: {
                  behavior: ['right', 'bottom-end']
                },
                preventOverflow: {
                  enabled: true,
                  priority: ['right', 'left'],
                  padding: 0,
                  boundariesElement: 'viewport'
                },
                hide: {
                  enabled: true
                }
              },
              results: {
                resultsPerPage: 5
              }
            }
          }
        }
      }
      */
    ]
  }
}

// Attach configuration to the window
window.inbAppSdk = inbApp;

// Polyfill: currentScript
!function(r){if(!("currentScript"in r)){var t=r.getElementsByTagName("script");Object.defineProperty(r,"currentScript",{get:function(){try{throw new Error}catch(n){var r,e=(/.*at [^\(]*\((.*):.+:.+\)$/gi.exec(n.stack)||[!1])[1];for(r in t)if(t[r].src==e||"interactive"==t[r].readyState)return t[r];return null}}})}}(document); // eslint-disable-line
var scriptPath = document.currentScript.src.split('/').slice(0, -2).join('/');
// Inbenta routes - Relative paths where the CSS and JS are hosted
var inbPaths = {
  css: scriptPath + '/assets/css/inbenta-core.css',
  js: scriptPath + '/assets/js/inbenta-core.js'
}

// Create CSS core file
var inbScriptCSS = document.createElement('link');
inbScriptCSS.type = 'text/css';
inbScriptCSS.rel = 'stylesheet';
inbScriptCSS.href = inbPaths.css;
document.head.appendChild(inbScriptCSS);

// Create JS core file
var inbScriptJS = document.createElement('script');
inbScriptJS.src = inbPaths.js;
document.head.appendChild(inbScriptJS);
