# Workflow Health Monitor

## Overview
This meta-workflow continuously monitors all other workflows in your n8n system, tracking performance, detecting failures, and ensuring optimal operation of your AI-augmented project management system.

## Workflow Components

### 1. Trigger: Multi-Source
- **Schedule**: Every hour for routine checks
- **Webhook**: Immediate alerts from failed workflows
- **Manual**: On-demand health checks
- **Event**: After system updates or changes

### 2. Collect Workflow Metrics

#### 2a. Get All Workflow Executions
```javascript
const collectWorkflowMetrics = async () => {
  const timeframe = {
    start: new Date(Date.now() - 24 * 60 * 60 * 1000), // Last 24 hours
    end: new Date()
  };
  
  const workflows = [
    'intelligent-inbox-processing',
    'epic-creation-cascade',
    'dynamic-entity-update',
    'smart-dependency-management',
    'retrospective-knowledge-capture',
    'intelligent-duplicate-detection',
    'cross-project-insights',
    'llm-context-management',
    'personalized-learning-engine'
  ];
  
  const metrics = {};
  
  for (const workflow of workflows) {
    const executions = await n8n.getExecutions(workflow, timeframe);
    
    metrics[workflow] = {
      total_executions: executions.length,
      successful: executions.filter(e => e.status === 'success').length,
      failed: executions.filter(e => e.status === 'error').length,
      running: executions.filter(e => e.status === 'running').length,
      average_duration: calculateAverageDuration(executions),
      error_rate: calculateErrorRate(executions),
      performance_trend: calculatePerformanceTrend(executions)
    };
  }
  
  return metrics;
};
```

#### 2b. Get System Resource Usage
```javascript
const getSystemMetrics = async () => {
  return {
    cpu_usage: await getCPUUsage(),
    memory_usage: await getMemoryUsage(),
    api_quota_usage: {
      notion: await getNotionAPIUsage(),
      openai: await getOpenAIUsage(),
      total_requests: await getTotalAPIRequests()
    },
    database_performance: {
      query_time: await getAverageQueryTime(),
      connection_pool: await getConnectionPoolStatus()
    },
    queue_metrics: {
      pending_items: await getQueueLength(),
      processing_rate: await getProcessingRate()
    }
  };
};
```

### 3. Analyze Workflow Health

#### 3a. Performance Analysis
```javascript
const analyzePerformance = (metrics) => {
  const analysis = {
    bottlenecks: [],
    degrading_performance: [],
    optimization_opportunities: []
  };
  
  // Identify bottlenecks
  for (const [workflow, data] of Object.entries(metrics)) {
    if (data.average_duration > thresholds[workflow].duration) {
      analysis.bottlenecks.push({
        workflow: workflow,
        current_duration: data.average_duration,
        expected_duration: thresholds[workflow].duration,
        severity: calculateSeverity(data.average_duration, thresholds[workflow].duration)
      });
    }
    
    // Check performance trends
    if (data.performance_trend < -0.1) { // 10% degradation
      analysis.degrading_performance.push({
        workflow: workflow,
        trend: data.performance_trend,
        likely_cause: analyzeDegradationCause(workflow, metrics)
      });
    }
  }
  
  // Identify optimization opportunities
  analysis.optimization_opportunities = identifyOptimizations(metrics);
  
  return analysis;
};
```

#### 3b. Error Pattern Detection
```javascript
const detectErrorPatterns = async (metrics) => {
  const errorPatterns = {
    recurring_errors: [],
    error_clusters: [],
    cascade_failures: [],
    root_causes: []
  };
  
  // Analyze error logs
  for (const [workflow, data] of Object.entries(metrics)) {
    if (data.failed > 0) {
      const errorLogs = await getErrorLogs(workflow);
      
      // Find recurring errors
      const groupedErrors = groupErrorsByType(errorLogs);
      for (const [errorType, errors] of Object.entries(groupedErrors)) {
        if (errors.length > 2) {
          errorPatterns.recurring_errors.push({
            workflow: workflow,
            error_type: errorType,
            frequency: errors.length,
            last_occurrence: errors[errors.length - 1].timestamp,
            suggested_fix: suggestFix(errorType, workflow)
          });
        }
      }
      
      // Detect error clusters (multiple errors in short time)
      const clusters = detectTimeClusters(errorLogs);
      if (clusters.length > 0) {
        errorPatterns.error_clusters.push({
          workflow: workflow,
          clusters: clusters,
          potential_cause: analyzeclusterCause(clusters)
        });
      }
    }
  }
  
  // Check for cascade failures
  errorPatterns.cascade_failures = detectCascadeFailures(metrics);
  
  return errorPatterns;
};
```

### 4. AI Health Diagnosis (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyze the health metrics of the workflow system and provide:\n1. Overall system health assessment\n2. Critical issues requiring immediate attention\n3. Performance optimization recommendations\n4. Predictive warnings for potential future issues\n5. Root cause analysis for any problems\n\nBe specific and actionable in recommendations."
    },
    {
      "role": "user",
      "content": "Workflow Metrics: {{JSON.stringify($node['Collect Workflow Metrics'].json)}}\n\nSystem Metrics: {{JSON.stringify($node['Get System Resource Usage'].json)}}\n\nPerformance Analysis: {{JSON.stringify($node['Analyze Performance'].json)}}\n\nError Patterns: {{JSON.stringify($node['Detect Error Patterns'].json)}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000
}
```

### 5. Generate Health Report
```javascript
const generateHealthReport = (aiAnalysis, metrics, analysis) => {
  const healthScore = calculateOverallHealthScore(metrics, analysis);
  
  return {
    summary: {
      overall_health: healthScore,
      status: getHealthStatus(healthScore), // 'healthy', 'warning', 'critical'
      last_check: new Date(),
      next_scheduled_check: new Date(Date.now() + 60 * 60 * 1000)
    },
    
    workflow_status: Object.entries(metrics).map(([workflow, data]) => ({
      workflow: workflow,
      health: calculateWorkflowHealth(data),
      metrics: {
        success_rate: (data.successful / data.total_executions * 100).toFixed(2) + '%',
        avg_duration: data.average_duration + 'ms',
        error_rate: data.error_rate + '%',
        trend: data.performance_trend > 0 ? 'improving' : 'degrading'
      },
      issues: analysis.bottlenecks.filter(b => b.workflow === workflow)
    })),
    
    critical_issues: aiAnalysis.critical_issues,
    
    recommendations: {
      immediate: aiAnalysis.immediate_actions,
      short_term: aiAnalysis.short_term_recommendations,
      long_term: aiAnalysis.long_term_improvements
    },
    
    predictions: aiAnalysis.predictive_warnings,
    
    resource_usage: {
      api_limits: {
        notion: `${metrics.api_quota_usage.notion.used}/${metrics.api_quota_usage.notion.limit}`,
        openai: `${metrics.api_quota_usage.openai.used}/${metrics.api_quota_usage.openai.limit}`
      },
      system_resources: {
        cpu: metrics.cpu_usage + '%',
        memory: metrics.memory_usage + '%'
      }
    }
  };
};
```

### 6. Auto-Remediation Actions

#### 6a. Automatic Fixes
```javascript
const autoRemediation = {
  // Restart stuck workflows
  restartStuckWorkflows: async (stuckWorkflows) => {
    for (const workflow of stuckWorkflows) {
      if (workflow.stuck_duration > 300000) { // 5 minutes
        await n8n.stopExecution(workflow.execution_id);
        await n8n.retryExecution(workflow.execution_id);
        
        await logRemediation({
          action: 'restart_stuck_workflow',
          workflow: workflow.name,
          execution_id: workflow.execution_id,
          reason: 'Execution stuck for over 5 minutes'
        });
      }
    }
  },
  
  // Clear queue congestion
  optimizeQueues: async (queueMetrics) => {
    if (queueMetrics.pending_items > 100) {
      // Increase processing parallelism
      await adjustWorkflowConcurrency('intelligent-inbox-processing', 5);
      
      // Redistribute load
      await enableLoadBalancing();
    }
  },
  
  // Handle API rate limits
  handleRateLimits: async (apiMetrics) => {
    for (const [api, usage] of Object.entries(apiMetrics)) {
      if (usage.used / usage.limit > 0.8) { // 80% threshold
        await implementRateLimitMitigation(api);
      }
    }
  }
};
```

#### 6b. Preventive Actions
```javascript
const preventiveActions = {
  // Scale before issues occur
  predictiveScaling: async (predictions) => {
    if (predictions.high_load_expected) {
      await scaleResources(predictions.expected_load);
    }
  },
  
  // Optimize before degradation
  proactiveOptimization: async (performanceTrends) => {
    for (const workflow of performanceTrends.degrading) {
      await optimizeWorkflow(workflow);
    }
  }
};
```

### 7. Alert Management

#### 7a. Smart Alerting
```javascript
const alertManagement = {
  sendAlert: async (issue, severity) => {
    // Determine recipients based on severity
    const recipients = getAlertRecipients(severity);
    
    // Format alert based on channel
    const alerts = {
      email: formatEmailAlert(issue, severity),
      slack: formatSlackAlert(issue, severity),
      notion: formatNotionAlert(issue, severity)
    };
    
    // Send through appropriate channels
    if (severity === 'critical') {
      await sendMultiChannelAlert(alerts, recipients);
    } else {
      await sendSingleChannelAlert(alerts.slack, recipients);
    }
  },
  
  // Prevent alert fatigue
  deduplicateAlerts: async (newAlert, recentAlerts) => {
    const isDuplicate = recentAlerts.some(alert => 
      alert.type === newAlert.type && 
      alert.workflow === newAlert.workflow &&
      (Date.now() - alert.timestamp) < 3600000 // 1 hour
    );
    
    return !isDuplicate;
  }
};
```

### 8. Update Monitoring Dashboard

#### 8a. Real-time Dashboard Update
```javascript
const updateDashboard = async (healthReport) => {
  // Update Notion monitoring page
  await notion.updatePage({
    page_id: MONITORING_DASHBOARD_ID,
    properties: {
      'Overall Health': healthReport.summary.overall_health,
      'Last Updated': new Date().toISOString(),
      'Critical Issues': healthReport.critical_issues.length,
      'Status': healthReport.summary.status
    }
  });
  
  // Update charts
  await updateHealthCharts({
    workflow_health: healthReport.workflow_status,
    performance_trends: healthReport.performance_data,
    error_rates: healthReport.error_data
  });
};
```

### 9. Historical Analysis

#### 9a. Trend Analysis
```javascript
const analyzeTrends = async () => {
  const historicalData = await getHistoricalHealthData(days = 30);
  
  return {
    health_trend: calculateHealthTrend(historicalData),
    recurring_issues: identifyRecurringIssues(historicalData),
    improvement_areas: identifyImprovementAreas(historicalData),
    seasonal_patterns: detectSeasonalPatterns(historicalData)
  };
};
```

## Configuration

### Health Thresholds
```javascript
const thresholds = {
  'intelligent-inbox-processing': {
    duration: 5000, // 5 seconds
    error_rate: 5,  // 5%
    success_rate: 95 // 95%
  },
  'epic-creation-cascade': {
    duration: 10000, // 10 seconds
    error_rate: 3,
    success_rate: 97
  },
  // ... other workflows
  
  system: {
    cpu_limit: 80,      // 80%
    memory_limit: 85,   // 85%
    api_limit: 80,      // 80% of quota
    queue_limit: 100    // items
  }
};
```

### Alert Configuration
```javascript
const alertConfig = {
  channels: {
    email: {
      enabled: true,
      recipients: ['admin@example.com'],
      severity_threshold: 'warning'
    },
    slack: {
      enabled: true,
      webhook: process.env.SLACK_WEBHOOK,
      channel: '#workflow-alerts',
      severity_threshold: 'info'
    },
    notion: {
      enabled: true,
      database_id: ALERTS_DATABASE_ID,
      severity_threshold: 'warning'
    }
  },
  
  escalation: {
    critical: {
      immediate_alert: true,
      all_channels: true,
      include_remediation: true
    },
    warning: {
      delay: 300000, // 5 minutes
      channels: ['slack', 'notion']
    }
  }
};
```

## Example Health Reports

### Healthy System
```json
{
  "summary": {
    "overall_health": 98,
    "status": "healthy",
    "message": "All systems operating normally"
  },
  "recommendations": {
    "immediate": [],
    "short_term": ["Consider caching for frequent KB queries"],
    "long_term": ["Plan for scaling as usage grows"]
  }
}
```

### System with Issues
```json
{
  "summary": {
    "overall_health": 72,
    "status": "warning",
    "message": "Multiple workflows experiencing delays"
  },
  "critical_issues": [
    {
      "workflow": "intelligent-inbox-processing",
      "issue": "High error rate (15%)",
      "cause": "OpenAI API timeouts",
      "action": "Implementing retry logic with backoff"
    }
  ],
  "recommendations": {
    "immediate": ["Increase OpenAI timeout", "Add fallback LLM"],
    "short_term": ["Optimize prompt size", "Implement caching"],
    "long_term": ["Consider local LLM for basic tasks"]
  }
}
```

## Integration Points

### Monitors These Workflows:
- All production workflows
- System resources
- External API usage
- Database performance

### Triggers:
- Auto-remediation workflows
- Alert systems
- Scaling operations
- Backup procedures

## Benefits

### Proactive Management
- Detect issues before users notice
- Prevent cascade failures
- Optimize performance continuously

### Reduced Downtime
- Automatic recovery from common issues
- Quick identification of root causes
- Predictive maintenance

### Performance Optimization
- Identify bottlenecks
- Track optimization impact
- Data-driven improvements

## Future Enhancements

1. **Machine Learning Predictions**: Predict failures before they occur
2. **Automated Testing**: Run synthetic tests to verify functionality
3. **Cost Optimization**: Monitor and optimize API usage costs
4. **Multi-Region Monitoring**: Support for distributed deployments
5. **Custom Health Metrics**: User-defined health indicators
6. **Integration with APM Tools**: Connect with DataDog, New Relic, etc.