#include <iterator>
#include <ranges>
#include <regex>
#include <sstream>
#include <string>
#include <vector>

namespace aoc {
inline std::vector<std::string> split(const std::string &input,
                                      const char delimiter) {
  std::vector<std::string> result;
  std::istringstream ss(input);
  std::string token;

  while (std::getline(ss, token, delimiter)) {
    result.push_back(token);
  }

  return result;
}

template <typename T>
inline std::string to_string(const std::vector<T> &input) {
  std::stringstream ss;
  for (const auto &s : input) {
    ss << s << ",";
  }

  std::string output = ss.str();
  if (output.length() > 0) {
    output.pop_back();
  }
  return output;
}

inline std::string repeat(const std::string &input, const int repeatCount) {
  std::stringstream ss;
  for (int i = 0; i < repeatCount; i++) {
    ss << input;
  }
  return ss.str();
}

// Trim from the start (in place)
inline void ltrim(std::string &s) {
  s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
            return !std::isspace(ch);
          }));
}

// Trim from the end (in place)
inline void rtrim(std::string &s) {
  s.erase(std::find_if(s.rbegin(), s.rend(),
                       [](unsigned char ch) { return !std::isspace(ch); })
              .base(),
          s.end());
}

inline void trim(std::string &s) {
  ltrim(s);
  rtrim(s);
}

class RegexMatchers {
private:
  std::regex m_regex;
  std::string m_input;

public:
  RegexMatchers(const std::string &regex, const std::string &str)
      : m_regex(regex), m_input(str) {}

  RegexMatchers(const std::regex &regex, const std::string &str)
      : m_regex(regex), m_input(str) {}

  std::sregex_iterator begin() const {
    return std::sregex_iterator(m_input.begin(), m_input.end(), m_regex);
  }

  std::sregex_iterator end() const { return std::sregex_iterator{}; }

  size_t count() const { return std::distance(begin(), end()); }
};

} // namespace aoc
