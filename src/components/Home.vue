<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm sticky top-0 z-10">
      <div
        class="container mx-auto px-4 py-4 flex flex-col md:flex-row justify-between items-center gap-4"
      >
        <div class="flex items-center space-x-2">
          <h1 class="text-xl md:text-2xl font-bold text-gray-800">
            TQM Ad List 规则列表
          </h1>
        </div>
        <div class="flex items-center space-x-4">
          <div class="flex space-x-6">
            <a
              href="/list/adlist.txt"
              class="text-black hover:text-gray-600 transition-colors flex items-center"
            >
              <i class="fa fa-link mr-2"></i> 规则源
            </a>
            <a
              href="https://github.com/MengXin001/ad-list"
              class="text-black hover:text-gray-600 transition-colors flex items-center"
            >
              <i class="fa fa-github mr-2"></i> GitHub
            </a>
          </div>

          <div class="flex items-center space-x-2">
            <select
              v-model="selectedSource"
              @change="refreshRules"
              class="px-3 py-1 rounded-md border border-gray-300 text-sm"
            >
              <option value="tqm">基础规则</option>
              <option value="pack">整合规则</option>
            </select>
          </div>
        </div>
      </div>
    </header>

    <main class="container mx-auto px-8 py-8">
      <div>
        <div class="bg-white rounded-xl shadow-md p-6 mb-8">
          <h2 class="text-xl font-bold mb-3 text-gray-800">关于过滤规则</h2>
          <p class="text-gray-600 mb-4">
            规则列表适用于ADGuardHome，用于丢弃和污染广告、追踪器、其他不需要的网络请求等域名的DNS解析。
            配合Easylist、Easylist-China和Halflife完善DNS过滤效果。
          </p>
          <div class="flex flex-wrap gap-3">
            <div class="flex items-center bg-blue-50 px-3 py-1 rounded-full">
              <span class="rule-type-badge bg-block text-white">屏蔽域名</span>
              <span class="text-sm text-gray-600">如: ||ut.taobao.com^</span>
            </div>
            <div class="flex items-center bg-blue-50 px-3 py-1 rounded-full">
              <span class="rule-type-badge bg-pattern text-white"
                >正则规则</span
              >
              <span class="text-sm text-gray-600">如: /ad-sign.*/</span>
            </div>
            <div class="flex items-center bg-blue-50 px-3 py-1 rounded-full">
              <span class="rule-type-badge bg-allow text-white">豁免域名</span>
              <span class="text-sm text-gray-600"
                >如: @@||analytics.moexin.cn</span
              >
            </div>
          </div>

          <div class="mt-6 p-4 bg-gray-50 rounded-lg">
            <h3 class="font-semibold mb-2">规则统计</h3>
            <div class="flex flex-wrap gap-4">
              <div class="flex items-center">
                <span class="rule-type-badge bg-block text-white"
                  >屏蔽域名</span
                >
                <span class="ml-2 font-medium">{{ domainCount }}</span>
              </div>
              <div class="flex items-center">
                <span class="rule-type-badge bg-pattern text-white"
                  >正则规则</span
                >
                <span class="ml-2 font-medium">{{ patternCount }}</span>
              </div>
              <div class="flex items-center">
                <span class="rule-type-badge bg-allow text-white"
                  >豁免域名</span
                >
                <span class="ml-2 font-medium">{{ allowCount }}</span>
              </div>
              <div class="flex items-center">
                <span class="text-gray-600 font-medium">总计:</span>
                <span class="ml-2 font-bold">{{ totalCount }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="mb-6">
          <div class="relative">
            <i
              class="fa fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            ></i>
            <input
              v-model="searchTerm"
              type="text"
              placeholder="搜索规则..."
              class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/50"
            />
          </div>
          <div class="flex flex-wrap gap-2 mt-3">
            <button
              v-for="(filter, key) in filterOptions"
              :key="key"
              @click="activeFilter = key"
              :class="[
                'px-3 py-1 rounded-full text-sm',
                activeFilter === key
                  ? 'bg-primary text-white'
                  : 'bg-gray-200 hover:bg-gray-300',
              ]"
            >
              {{ filter }}
            </button>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <section class="lg:col-span-1">
            <h2 class="section-title">
              <span class="rule-type-badge bg-block text-white">屏蔽域名</span>
              <span>规则列表 ({{ filteredRules.domain.length }})</span>
            </h2>
            <div class="space-y-2">
              <div
                v-for="(rule, idx) in showAllDomain
                  ? filteredRules.domain
                  : filteredRules.domain.slice(0, MAX_VISIBLE)"
                :key="rule"
                class="rule-card"
                data-type="domain"
              >
                <div class="flex justify-between items-center">
                  <div class="font-mono text-sm text-gray-800">{{ rule }}</div>
                  <button
                    @click="copyRule(rule)"
                    class="copy-btn text-gray-400 hover:text-primary transition-colors"
                  >
                    <i class="fa fa-copy"></i>
                  </button>
                </div>
              </div>
              <button
                v-if="filteredRules.domain.length > MAX_VISIBLE"
                class="mt-2 px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 text-sm w-full"
                @click="showAllDomain = !showAllDomain"
              >
                {{
                  showAllDomain
                    ? "收起"
                    : `显示全部 (${filteredRules.domain.length})`
                }}
              </button>
            </div>
          </section>

          <section class="lg:col-span-1">
            <h2 class="section-title">
              <span class="rule-type-badge bg-pattern text-white"
                >正则规则</span
              >
              <span>规则列表 ({{ filteredRules.pattern.length }})</span>
            </h2>
            <div class="space-y-2">
              <div
                v-for="(rule, idx) in showAllPattern
                  ? filteredRules.pattern
                  : filteredRules.pattern.slice(0, MAX_VISIBLE)"
                :key="rule"
                class="rule-card"
                data-type="pattern"
              >
                <div class="flex justify-between items-center">
                  <div class="font-mono text-sm text-gray-800">{{ rule }}</div>
                  <button
                    @click="copyRule(rule)"
                    class="copy-btn text-gray-400 hover:text-primary transition-colors"
                  >
                    <i class="fa fa-copy"></i>
                  </button>
                </div>
              </div>
              <button
                v-if="filteredRules.pattern.length > MAX_VISIBLE"
                class="mt-2 px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 text-sm w-full"
                @click="showAllPattern = !showAllPattern"
              >
                {{
                  showAllPattern
                    ? "收起"
                    : `显示全部 (${filteredRules.pattern.length})`
                }}
              </button>
            </div>
          </section>

          <section class="lg:col-span-2">
            <h2 class="section-title">
              <span class="rule-type-badge bg-allow text-white">豁免域名</span>
              <span>规则列表 ({{ filteredRules.allow.length }})</span>
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
              <div
                v-for="(rule, idx) in showAllAllow
                  ? filteredRules.allow
                  : filteredRules.allow.slice(0, MAX_VISIBLE)"
                :key="rule"
                class="rule-card"
                data-type="allow"
              >
                <div class="flex justify-between items-center">
                  <div class="font-mono text-sm text-gray-800">{{ rule }}</div>
                  <button
                    @click="copyRule(rule)"
                    class="copy-btn text-gray-400 hover:text-primary transition-colors"
                  >
                    <i class="fa fa-copy"></i>
                  </button>
                </div>
              </div>
              <button
                v-if="filteredRules.allow.length > MAX_VISIBLE"
                class="mt-2 px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 text-sm w-full md:col-span-2"
                @click="showAllAllow = !showAllAllow"
              >
                {{
                  showAllAllow
                    ? "收起"
                    : `显示全部 (${filteredRules.allow.length})`
                }}
              </button>
            </div>
          </section>
        </div>
      </div>
    </main>

    <div
      id="notification"
      class="fixed bottom-4 right-4 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg transform transition-all duration-300 flex items-center"
      :class="{
        'translate-y-0 opacity-100': showNotification,
        'translate-y-20 opacity-0': !showNotification,
      }"
    >
      <i
        class="fa"
        :class="
          notificationType === 'success'
            ? 'fa-check-circle mr-2 text-green-400'
            : 'fa-exclamation-circle mr-2 text-red-400'
        "
      ></i>
      <span>{{ notificationMessage }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import axios from "axios";

const TQM_RULES_URL =
  "/list/adlist.txt";
const PACK_RULES_URL =
  "/list/pack_adlist.txt";

const allRules = ref([]);
const searchTerm = ref("");
const activeFilter = ref("all");
const showNotification = ref(false);
const notificationMessage = ref("");
const notificationType = ref("success");
const loading = ref(false);
const error = ref(null);
const selectedSource = ref("tqm");

const filterOptions = {
  all: "全部",
  domain: "屏蔽域名",
  pattern: "正则规则",
  allow: "豁免域名",
};

const MAX_VISIBLE = 15;
const showAllDomain = ref(false);
const showAllPattern = ref(false);
const showAllAllow = ref(false);

const filteredRules = computed(() => {
  let filtered = {
    domain: [],
    pattern: [],
    allow: [],
  };

  allRules.value.forEach((rule) => {
    if (rule.startsWith("@@")) {
      filtered.allow.push(rule);
    } else if (rule.startsWith("/")) {
      filtered.pattern.push(rule);
    } else {
      filtered.domain.push(rule);
    }
  });

  if (searchTerm.value) {
    const term = searchTerm.value.toLowerCase();
    Object.keys(filtered).forEach((key) => {
      filtered[key] = filtered[key].filter((rule) =>
        rule.toLowerCase().includes(term)
      );
    });
  }

  if (activeFilter.value !== "all") {
    Object.keys(filtered).forEach((key) => {
      if (key !== activeFilter.value) {
        filtered[key] = [];
      }
    });
  }

  return filtered;
});

// 统计
const domainCount = computed(
  () =>
    allRules.value.filter(
      (rule) => !rule.startsWith("@@") && !rule.startsWith("/")
    ).length
);
const patternCount = computed(
  () => allRules.value.filter((rule) => rule.startsWith("/")).length
);
const allowCount = computed(
  () => allRules.value.filter((rule) => rule.startsWith("@@")).length
);
const totalCount = computed(() => allRules.value.length);

const getRules = async () => {
  loading.value = true;
  error.value = null;
  try {
    const url = selectedSource.value === "tqm" ? TQM_RULES_URL : PACK_RULES_URL;
    const response = await axios.get(url);
    const rules = response.data
      .split("\n")
      .map((rule) => rule.trim())
      .filter((rule) => rule && !rule.startsWith("#"));
    allRules.value = rules;
    showNotificationMessage("规则加载成功", "success");
  } catch (err) {
    console.error("获取规则失败:", err);
    error.value = "获取规则失败，请检查网络连接";
    showNotificationMessage("获取规则失败", "error");
  } finally {
    loading.value = false;
  }
};

const refreshRules = () => {
  showAllDomain.value = false;
  showAllPattern.value = false;
  showAllAllow.value = false;
  getRules();
};

const copyRule = (rule) => {
  navigator.clipboard
    .writeText(rule)
    .then(() => showNotificationMessage("规则已复制", "success"))
    .catch(() => showNotificationMessage("复制失败，请手动复制", "error"));
};

const showNotificationMessage = (message, type) => {
  notificationMessage.value = message;
  notificationType.value = type;
  showNotification.value = true;
  setTimeout(() => {
    showNotification.value = false;
  }, 2000);
};

onMounted(() => {
  getRules();
});
</script>

<style scoped>
.rule-card {
  @apply bg-white rounded-lg shadow-md p-4 mb-3 transition-all duration-300 hover:shadow-lg;
}

.rule-type-badge {
  @apply text-xs font-semibold px-2 py-1 rounded-full mr-2;
}

.section-title {
  @apply text-xl font-bold mb-4 flex items-center;
}

.bg-block {
  background-color: #ef4444;
}

.bg-allow {
  background-color: #10b981;
}

.bg-pattern {
  background-color: #f59e0b;
}

.bg-primary {
  background-color: #3b82f6;
}
</style>
