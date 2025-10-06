# GitHub Actions 云端编译 Audio HAL 指南

## 📋 概述

使用GitHub Actions免费云端Linux环境编译修改后的Audio HAL库。

**优势：**
- ✅ **完全免费** - GitHub对公共仓库提供免费的CI/CD
- ✅ **无需本地Linux** - 在GitHub云端完成编译
- ✅ **可重复** - 每次推送代码自动编译
- ✅ **保存产物** - 自动保存编译结果30天

**限制：**
- ⚠️ 每月2000分钟免费额度
- ⚠️ 单次运行最长6小时
- ⚠️ 需要公开仓库（或GitHub Pro）

---

## 🚀 使用步骤

### **步骤1：准备GitHub仓库**

```bash
# 进入sipclient目录
cd /Users/liaimin/Code/sipclient

# 初始化Git仓库（如果还没有）
git init

# 创建hal_source目录
mkdir -p hal_source

# 复制修改后的HAL源码
cp -r "/Volumes/My Passport/code/docker/lineageos-source/hardware/qcom/audio/hal"/* hal_source/

# 添加到Git
git add .
git commit -m "Add modified HAL source for cloud build"
```

### **步骤2：推送到GitHub**

1. 在GitHub上创建新仓库（必须是**公开仓库**才能免费使用）：
   - 仓库名：`sipclient-hal-build`（或任意名称）
   - 可见性：**Public**

2. 推送代码：
```bash
git remote add origin https://github.com/YOUR_USERNAME/sipclient-hal-build.git
git branch -M main
git push -u origin main
```

### **步骤3：触发云端编译**

#### 方式A：通过GitHub网页界面
1. 打开仓库页面
2. 点击 **Actions** 标签
3. 选择 **Build Audio HAL** 工作流
4. 点击 **Run workflow** → **Run workflow**
5. 等待编译完成（约10-30分钟）

#### 方式B：推送代码自动触发
```bash
# 修改hal_source/中的文件后
git add hal_source/
git commit -m "Update HAL source"
git push
```

### **步骤4：下载编译产物**

1. 编译完成后，在Actions页面找到最新的运行
2. 向下滚动到 **Artifacts** 部分
3. 下载 **audio-hal-build** 压缩包
4. 解压后得到 `audio.primary.*.so` 文件

### **步骤5：推送到设备**

```bash
# 解压下载的文件
unzip audio-hal-build.zip

# 推送到设备
adb root
adb remount
adb push audio.primary.msm8937.so /vendor/lib/hw/
adb shell chmod 644 /vendor/lib/hw/audio.primary.msm8937.so
adb shell killall audioserver
adb reboot
```

---

## ⚠️ 重要说明

### **当前配置的局限性**

当前的GitHub Actions配置是**简化版本**，可能无法完全编译HAL，因为：
- 缺少完整的Android源码树
- 缺少所有依赖库
- 需要大量的预编译工具

### **完整编译方案（推荐）**

如果简化版本编译失败，可以修改工作流下载完整的LineageOS源码：

**修改 `.github/workflows/build_hal.yml`：**

```yaml
# 在 "下载LineageOS源码" 步骤中替换为：
- name: 下载完整LineageOS源码
  run: |
    # 安装repo工具
    mkdir -p ~/bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    export PATH=~/bin:$PATH
    
    # 初始化LineageOS 21.0源码
    mkdir -p ~/lineageos
    cd ~/lineageos
    repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --depth=1
    
    # 只同步必要的部分（减少时间）
    repo sync -c -j4 --force-sync --no-clone-bundle --no-tags \
      build/make \
      build/soong \
      hardware/qcom/audio \
      prebuilts/gcc/linux-x86/aarch64 \
      system/core \
      external/tinyalsa
    
    # 然后复制修改后的HAL覆盖原文件
    cp -r $GITHUB_WORKSPACE/hal_source/* hardware/qcom/audio/hal/
```

**注意：完整编译需要：**
- ⏱️ 约40-60分钟
- 💾 约30GB磁盘空间
- 🔋 消耗较多免费额度

---

## 🔧 故障排查

### **编译失败：缺少依赖**
**解决方案：** 使用完整编译方案（见上文）

### **GitHub Actions额度用尽**
**解决方案：** 
- 等待下个月重置（每月1号）
- 或升级到GitHub Pro（无限私有仓库额度）

### **仍然无法编译**
**建议：** 
- 使用本地Linux虚拟机编译（最可靠）
- 或租用云服务器（AWS/阿里云学生机）

---

## 💡 替代方案：Docker Hub自动构建

另一个免费方案是使用Docker Hub的自动构建功能：

1. 创建Dockerfile包含完整编译环境
2. 关联GitHub仓库
3. 每次推送自动构建Docker镜像
4. 从镜像中提取编译产物

详情请参考：`DOCKER_HUB_BUILD.md`（待创建）

---

## 📞 需要帮助？

如果遇到问题，可以：
1. 查看GitHub Actions日志详细信息
2. 检查 `BUILD_REPORT.txt`
3. 考虑使用本地Linux环境编译（更稳定）
