class Alexandria
  class AuthenticationFailure < StandardError
    DOCS_URL = "http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html"

    def initialize(code)
      @code = code
      @error = FailureCodes.const_get(code)
    rescue NameError
      raise NameError, "Google responded with #{@code}, but did not document that code. " \
                       "Please visit #{DOCS_URL} for possibly updated information"
    end

    def message
      "Google responded to your authentication request with the " \
      "code #{@code}, which is describes as `#{@error}`"
    end
  end

  module FailureCodes
    BadAuthentication  = "The login request used a username or password that is not recognized. NOTE: This may also result from having specified an invalid service"
    NotVerified        = "The account email address has not been verified. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application."
    TermsNotAgreed     = "The user has not agreed to terms. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application."
    CaptchaRequired    = "A CAPTCHA is required. (A response with this error code will also contain an image URL and a CAPTCHA token.)"
    Unknown            = "The error is unknown or unspecified; the request contained invalid input or was malformed."
    AccountDeleted     = "The user account has been deleted."
    AccountDisabled    = "The user account has been disabled."
    ServiceDisabled    = "The user's access to the specified service has been disabled. (The user account may still be valid.)"
    ServiceUnavailable = "The service is not available; try again later."
  end

  class InvalidServiceName < StandardError
    def initialize(name, valid)
      @name, @valid = name, valid
    end

    def message
      valids = @valid.map {|v| "* #{v.inspect}" }.join("\n")

      "You specified #{@name.inspect} as the service name.\n\nThis was an " \
      "invalid service name.\n\nIf you wish to add a new service, " \
      "use:\n> Alexandria.add_service(:name, 'str')\n\nThe list of valid " \
      "names is:\n#{valids}"
    end
  end

  module ServiceNames
    NAMES = {}

    def self.[](name)
      if name.is_a?(Symbol) && !NAMES.key?(name)
        raise InvalidServiceName.new(name, NAMES.keys)
      end

      value = name.is_a?(Symbol) ? NAMES[name] : name

      unless NAMES.values.include?(value)
        raise InvalidServiceName.new(value, NAMES.values)
      end

      value
    end
  end

  def self.add_service(symbol, string)
    ServiceNames::NAMES[symbol] = string
  end

  add_service :analytics,       "analytics"
  add_service :apps,            "apps"
  add_service :base,            "gbase"
  add_service :sites,           "jotspot"
  add_service :blogger,         "blogger"
  add_service :book_search,     "print"
  add_service :calendar,        "cl"
  add_service :code_search,     "code_search"
  add_service :contacts,        "cp"
  add_service :documents,       "writely"
  add_service :finance,         "finance"
  add_service :gmail,           "mail"
  add_service :health,          "health"
  add_service :maps,            "local"
  add_service :picasa,          "lh2"
  add_service :sidewiki,        "annotateweb"
  add_service :spreadsheets,    "wise"
  add_service :webmaster_tools, "sitemaps"
  add_service :youtube,         "youtube"

end