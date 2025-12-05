#pragma once

#include "fmt/format.h"
#include "spdlog/sinks/base_sink.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "gtest/gtest.h"
#include <initializer_list>
#include <memory>
#include <spdlog/logger.h>
#include <spdlog/spdlog.h>
#include <vector>

namespace aoc {

// Custom sink that buffers messages per test
template <typename Mutex>
class buffered_test_sink : public spdlog::sinks::base_sink<Mutex> {
private:
  std::vector<std::string> buffer_;
  std::shared_ptr<spdlog::sinks::sink> target_sink_;

protected:
  void sink_it_(const spdlog::details::log_msg &msg) override {
    spdlog::memory_buf_t formatted;
    this->formatter_->format(msg, formatted);
    std::string line = fmt::to_string(formatted);
    // Remove trailing newline if present
    if (!line.empty() && line.back() == '\n') {
      line.pop_back();
    }
    buffer_.push_back(line);
  }

  void flush_() override {
    if (target_sink_) {
      target_sink_->flush();
    }
  }

public:
  buffered_test_sink(std::shared_ptr<spdlog::sinks::sink> target)
      : target_sink_(target) {}

  void flush_buffer() {
    for (const auto &line : buffer_) {
      spdlog::details::log_msg msg(spdlog::source_loc{}, "",
                                   spdlog::level::info, line);
      target_sink_->log(msg);
    }
    target_sink_->flush();
    buffer_.clear();
  }

  void clear_buffer() { buffer_.clear(); }
};

using buffered_test_sink_mt = buffered_test_sink<std::mutex>;

class SelectiveLogFlushListener : public testing::EmptyTestEventListener {
private:
  std::shared_ptr<buffered_test_sink_mt> m_buffered_sink;

public:
  SelectiveLogFlushListener(const std::shared_ptr<buffered_test_sink_mt> sink)
      : m_buffered_sink(sink) {}

  void OnTestEnd(const testing::TestInfo &test_info) override {
    if (!test_info.result()->Passed()) {
      m_buffered_sink->flush_buffer();
    } else {
      m_buffered_sink->clear_buffer();
    }
  }
};

class SpdlogTestListener : public testing::EmptyTestEventListener {
private:
  std::string current_suite;
  std::string current_case;

public:
  void OnTestStart(const testing::TestInfo &test_info) override {
    current_suite = test_info.test_suite_name();
    current_case = test_info.name();
    spdlog::info("[{}::{}] Test started", current_suite, current_case);
  }

  void OnTestEnd(const testing::TestInfo &test_info) override {
    if (!test_info.result()->Passed()) {
      spdlog::error("[{}::{}] Test failed", current_suite, current_case);
    }
  }
};

class TestingEnvironment : public testing::Environment {
private:
  bool m_skipped = false;

public:
  TestingEnvironment(bool skipping) : m_skipped(skipping) {}

  void SetUp() override {
    if (m_skipped) {
      GTEST_SKIP() << " tests disabled";
    }
  }
};

inline int runUnitTests(int argc, char **argv, const std::string &testName,
                        bool disabled = false) {
  auto file_sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(
      fmt::format("logs/{}/error.log", testName), true);
  file_sink->set_pattern("%v");

  // Wrap it in our buffering sink
  auto buffered_sink = std::make_shared<buffered_test_sink_mt>(file_sink);

  // Create logger with the buffered sink
  auto logger = std::make_shared<spdlog::logger>(
      fmt::format("test-{}", testName), buffered_sink);

  logger->set_pattern("[%H:%M:%S.%e] %v");

  spdlog::set_default_logger(logger);

  testing::InitGoogleTest(&argc, argv);

  testing::TestEventListeners &listeners =
      testing::UnitTest::GetInstance()->listeners();
  listeners.Append(new SpdlogTestListener());
  listeners.Append(new SelectiveLogFlushListener(buffered_sink));

  testing::AddGlobalTestEnvironment(new TestingEnvironment(disabled));

  return RUN_ALL_TESTS();
}

template <typename T>
inline auto test_params(const std::initializer_list<T> params) {
  return testing::ValuesIn(params);
}
} // namespace aoc
