#pragma once

#include <string>
#include <string_view>

namespace clack {
   class config {
      public:
         config();
         ~config();

         void set_option(const std::string& option, const std::string& value);
         std::string get_option(const std::string& option) const;

      private:
         std::map<std::string, std::string> options_;
   };
}