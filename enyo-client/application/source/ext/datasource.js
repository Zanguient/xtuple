/*jshint indent:2, curly:true eqeqeq:true, immed:true, latedef:true,
newcap:true, noarg:true, regexp:true, undef:true, strict:true, trailing:true
white:true*/
/*global XT:true, XM:true, io:true, Backbone:true, _:true, console:true, enyo:true
  document:true, setTimeout:true*/

(function () {
  "use strict";

  XT.DataSource = {
    // TODO - Old way.
    //datasourceUrl: DOCUMENT_HOSTNAME,
    //datasourcePort: 443,
    isConnected: false,

    /**
      Helper function to convert parameters to data source friendly formats

      @param {String} Record Type
      @param {Object} Query parameters
    */
    formatParameters: function (recordType, params) {
      _.each(params, function (param) {
        var klass = recordType ? XT.getObjectByName(recordType) : null,
          relations = klass ? klass.prototype.relations : [],
          relation = _.find(relations, function (rel) {
            return rel.key === param.attribute;
          }),
          idAttribute;

        // Format date if applicable
        if (param.value instanceof Date) {
          param.value = param.value.toJSON();

        // Format record if applicable
        } else if (_.isObject(param.value) && !_.isArray(param.value)) {
          param.value = param.value.id;
        }

        // Format attribute if it's `HasOne` relation
        if (relation && relation.type === Backbone.HasOne && relation.isNested) {
          klass = XT.getObjectByName(relation.relatedModel);
          idAttribute = klass.prototype.idAttribute;
          param.attribute = param.attribute + '.' + idAttribute;
        }
      });
    },

    /*
    Returns a record array based on a query.

    @param {Object} query
    @param {Object} options
    */
    fetch: function (collection, options) {
      options = options ? _.clone(options) : {};
      var that = this,
        payload = {},
        parameters = options.query.parameters,
        complete = function (response) {
          var params = {}, error;

          // Handle error
          if (response.isError) {
            if (options && options.error) {
              params.error = response.message;
              error = XT.Error.clone('xt1001', { params: params });
              options.error.call(that, error);
            }
            return;
          }

          if (options && options.success) {
            options.success.call(that, collection, response.data, options);
          }
        };

      if (parameters && parameters.length) {
        this.formatParameters(options.query.recordType, parameters);
      }

      payload.requestType = 'fetch';
      payload.query = options.query;
      payload.databaseType = options.databaseType;

      return XT.Request
               .handle("function/fetch")
               .notify(complete)
               .send(payload);
    },

    /*
    Server request

    @param {Object} model
    @param {String} method
    @param {Object} payload
    @param {Object} options
    */
    request: function (model, method, payload, options) {
      var that = this,
        complete = function (response) {
          var dataHash,
            params = {},
            error,
            attrs;

          // Handle error
          if (response.isError) {
            if (options && options.error) {
              params.error = response.message;
              error = XT.Error.clone('xt1001', { params: params });
              options.error.call(that, error);
            }
            return;
          }
          
          dataHash = JSON.parse(response.rows[0].request);
          
          // Handle no data as error
          if (method === "get" && _.isEmpty(dataHash.data)) {
            if (options && options.error) {
              error = XT.Error.clone('xt1007');
              options.error.call(model, error);
            }
            return;
          }

          // Handle success
          if (options && options.success) {
            if (dataHash.patches) {
              attrs = model ?
                XM.jsonpatch.apply(model.toJSON(), dataHash.patches) :
                dataHash.patches;
            } else {
              attrs = dataHash.data;
            }
            if (model) {
              model.lock = dataHash.lock;
              model.version = dataHash.version;
            }
            options.success.call(that, model, attrs, options);
          }
        };

      return XT.Request
               .handle(method)
               .notify(complete)
               .send(JSON.stringify(payload));
    },

    /*
    Dispatch a server side function call to the datasource.

    @param {String} class name
    @param {String} function name
    @param {Object} parameters
    @param {Function} success callback
    @param {Function} error callback
    */
    dispatch: function (name, func, params, options) {
      var that = this,
        payload = {
          requestType: 'dispatch',
          className: name,
          functionName: func,
          parameters: params
        },
        complete = function (response) {
          var params = {}, error;

          // handle error
          if (response.isError) {
            if (options && options.error) {
              params.error = response.message;
              error = XT.Error.clone('xt1001', { params: params });
              options.error.call(that, error);
            }
            return;
          }

          if (options && options.success) {
            options.success.call(that, response.data, options);
          }
        };

      payload.automatedRefresh = options.automatedRefresh;
      payload.databaseType = options.databaseType;
      return XT.Request
               .handle('function/dispatch')
               .notify(complete)
               .send(payload);
    },

    /*
      Reset a global user's password.

    @param {String} id
    @param {Function} options.success callback
    @param {Function} options.error callback
    */
    resetPassword: function (id, options) {
      var payload = {
          id: id
        },
        ajax = new enyo.Ajax({
          url: "/resetPassword",
          success: options ? options.success : undefined,
          error: options ? options.error : undefined
        });

      if (options.newUser) {
        // we don't want to send false at all, because false turns
        // into "false" over the wire which is truthy.
        payload.newUser = options.newUser;
      }

      ajax.response(this.ajaxSuccess);
      ajax.go(payload);
    },
    /*
      Change a global password.

    @param {Object} parameters
    @param {Function} options.success callback
    @param {Function} options.error callback
    */
    changePassword: function (params, options) {
      var payload = {
          oldPassword: params.oldPassword,
          newPassword: params.newPassword
        },
        ajax = new enyo.Ajax({
          url: "/changePassword",
          success: options ? options.success : undefined,
          error: options ? options.error : undefined
        });

      ajax.response(this.ajaxSuccess);
      ajax.go(payload);
    },

    ajaxSuccess: function (inSender, inResponse) {
      var params = {}, error;

      // handle error
      if (inResponse.isError) {
        if (inSender.error) {
          params.error = inResponse.message;
          error = XT.Error.clone('xt1001', { params: params });
          inSender.error.call(this, error);
        }
        return;
      }

      // handle success
      if (inSender.success) {
        inSender.success.call(this, inResponse.data);
      }
    },
    /*
      Sends a request to node to send out an email

    @param {Object} payload
    @param {String} payload.from
    @param {String} payload.to
    @param {String} payload.cc
    @param {String} payload.bcc
    @param {String} payload.subject
    @param {String} payload.text
    */
    sendEmail: function (payload, options) {
      var ajax = new enyo.Ajax({
          url: "/email",
          success: options ? options.success : undefined,
          error: options ? options.error : undefined
        });

      if (payload.body && !payload.text) {
        // be flexible with the inputs. Node-emailer prefers the term text, but
        // body is fine for us as well.
        payload.text = payload.body;
      }
      ajax.response(this.ajaxSuccess);
      ajax.go(payload);
    },

    /*
      Determine the list of extensions in use by the user's
      organization.

    @param {Object} parameters
    @param {Function} options.success callback
    @param {Function} options.error callback
    */
    getExtensionList: function (options) {
      var ajax = new enyo.Ajax({
          url: "/extensions",
          success: options ? options.success : undefined,
          error: options ? options.error : undefined
        });

      ajax.response(this.ajaxSuccess);
      ajax.go();

    },

    /* @private */
    connect: function (callback) {
      if (this.isConnected) {
        if (callback && callback instanceof Function) {
          callback();
        }
        return;
      }

      XT.log("Attempting to connect to the datasource");

      var host = document.location.host,
          path = "clientsock",
          protocol = document.location.protocol,
          datasource = "%@//%@/%@".f(protocol, host, path),
          self = this,
          didConnect = this.sockDidConnect,
          didError = this.sockDidError;

      // Attempt to connect and supply the appropriate responders for the connect and error events.
      this._sock = io.connect(datasource, {secure: true});
      this._sock.on("connect", function () {
        //didConnect.call(self, callback);
      });
      this._sock.on("ok", function () {
        didConnect.call(self, callback);
      });
      this._sock.on("error", function (err) {
        // New express conneciton error doesn't send err message back here, but does call this.
        XT.log("SERVER ERROR.");
        didError.call(self, err, callback);
      });
      this._sock.on("connect_failed", function (err) {
        // This app has not even started yet. Don't bother with the popup because it won't work.
        XT.log("AUTHENTICATION INVALID: ", err);
        XT.logout();
        return;
      });

      this._sock.on("debug", function (msg) {
        XT.log("SERVER DEBUG => ", msg);
      });

      this._sock.on("timeout", function (msg) {
        XT.log("SERVER SAID YOU TIMED OUT");
        var p = XT.app.createComponent({
          kind: "onyx.Popup",
          centered: true,
          modal: true,
          floating: true,
          scrim: true,
          autoDismiss: false,
          style: "text-align: center;",
          components: [
            {content: "_sessionTimedOut".loc()},
            {kind: "onyx.Button", content: "_ok".loc(), tap: function () { XT.logout(); }}
          ]
        });
        p.show();
      });

      this._sock.on("disconnect", function () {
        XT.log("DISCONNECTED FROM SERVER");
      });
    },

    /* @private */
    sockDidError: function (err, callback) {
      // TODO: need some handling here
      console.warn(err);
      if (callback && callback instanceof Function) {
        callback(err);
      }
    },

    /* @private */
    sockDidConnect: function (callback) {

      XT.log("Successfully connected to the datasource");

      this.isConnected = true;

      // go ahead and create the session object for the
      // application if it does not already exist
      if (!XT.session) {
        XT.session = Object.create(XT.Session);
        setTimeout(_.bind(XT.session.start, XT.session), 0);
      }

      if (callback && callback instanceof Function) {
        callback();
      }
    },

    reset: function () {
      if (!this.isConnected) {
        return;
      }

      var sock = this._sock;
      if (sock) {
        sock.disconnect();
        this.isConnected = false;
      }

      this.connect();
    }

  };

  XT.dataSource = Object.create(XT.DataSource);

}());
