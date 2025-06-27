#!/bin/bash

echo "================================================"
echo "🚀 Starting Test Application"
echo "================================================"
echo "Build Context: example_direct_upload_test"
echo "Build Time: $(date)"
echo "Container ID: $(hostname)"
echo "================================================"

# 模拟应用启动
echo "📋 Application Configuration:"
echo "  - Name: Test Upload App"
echo "  - Version: 1.0.0" 
echo "  - Port: 8080"
echo "  - Environment: Container"

echo ""
echo "✅ Application started successfully!"
echo "📁 Current directory contents:"
ls -la

echo ""
echo "🔄 Starting simple HTTP server on port 8080..."

# 创建简单的 HTTP 响应
mkdir -p /tmp/www
cat > /tmp/www/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Upload App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .success { color: #28a745; }
        .info { color: #17a2b8; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">✅ Test Upload App</h1>
        <p class="info">This application was built from an uploaded build context!</p>
        <h3>Build Information:</h3>
        <ul>
            <li><strong>Build Context:</strong> example_direct_upload_test</li>
            <li><strong>Build Method:</strong> File Upload</li>
            <li><strong>Container:</strong> Alpine Linux</li>
            <li><strong>Build Time:</strong> {{ BUILD_TIME }}</li>
        </ul>
        <p>🎉 Jenkins file upload build system is working correctly!</p>
    </div>
</body>
</html>
EOF

# 替换构建时间
sed -i "s/{{ BUILD_TIME }}/$(date)/g" /tmp/www/index.html

# 健康检查端点
cat > /tmp/www/health << 'EOF'
OK
EOF

# 启动简单的 HTTP 服务器
cd /tmp/www
echo "🌐 Server starting at http://localhost:8080"
echo "🔍 Health check available at http://localhost:8080/health"

# 使用 busybox httpd 或 python 启动服务器
if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server 8080
elif command -v python >/dev/null 2>&1; then
    python -m SimpleHTTPServer 8080
else
    # 保持容器运行
    echo "⚠️  No Python available, keeping container alive..."
    tail -f /dev/null
fi 