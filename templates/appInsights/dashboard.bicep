param dashboardName string
param location string = resourceGroup().location
param resourceGroupName string
param aspNames string
param logicAppAspName string

resource asps 'Microsoft.Web/serverfarms@2024-04-01' existing = [
  for item in json(aspNames): {
    name: item.Name
    scope: resourceGroup(resourceGroupName)
  }
]

resource logicAppAsp 'Microsoft.Web/serverfarms@2024-04-01' existing = {
  name: logicAppAspName
  scope: resourceGroup(resourceGroupName)
}

resource FES 'Microsoft.Portal/dashboards@2022-12-01-preview' = {
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[0].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[0].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[0].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[0].name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[0].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[0].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[0].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[0].name
                          }
                        }
                      ]
                      title: 'Front Ends - ${asps[0].sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          {
            position: {
              x: 6
              y: 0
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[1].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[1].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[1].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[1].name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[1].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[1].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[1].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[1].name
                          }
                        }
                      ]
                      title: 'Batch Process - ${asps[1].sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          {
            position: {
              x: 12
              y: 0
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[2].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[2].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[2].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[2].name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[2].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[2].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[2].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[2].name
                          }
                        }
                      ]
                      title: 'Landings Consolidation - ${asps[2].sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          {
            position: {
              x: 0
              y: 4
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[3].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[3].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[3].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[3].name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[3].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[3].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[3].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[3].name
                          }
                        }
                      ]
                      title: 'Orcestration - ${asps[3].sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          {
            position: {
              x: 6
              y: 4
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[4].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[4].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[4].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[4].name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: asps[4].id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: asps[4].name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: asps[4].id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: asps[4].name
                          }
                        }
                      ]
                      title: 'Ref Data & Function App - ${asps[0].sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          {
            position: {
              x: 12
              y: 4
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: logicAppAsp.id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: logicAppAsp.name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: logicAppAsp.id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: logicAppAsp.name
                          }
                        }
                      ]
                      title: 'CPU Percentage'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 3600000
                        }
                        showUTCTime: false
                        grain: 2
                      }
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: logicAppAsp.id
                          }
                          name: 'CpuPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'CPU Percentage'
                            resourceDisplayName: logicAppAsp.name
                          }
                        }
                        {
                          resourceMetadata: {
                            id: logicAppAsp.id
                          }
                          name: 'MemoryPercentage'
                          aggregationType: 3
                          namespace: 'microsoft.web/serverfarms'
                          metricVisualization: {
                            displayName: 'Memory Percentage'
                            resourceDisplayName: logicAppAsp.name
                          }
                        }
                      ]
                      title: 'Logic Apps - ${logicAppAsp.sku.name}'
                      titleKind: 2
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideHoverCard: false
                          hideLabelNames: true
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
        ]
      }
    ]
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 1
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              model: {
                format: 'utc'
                granularity: 'auto'
                relative: '30d'
              }
              displayCache: {
                name: 'UTC Time'
                value: 'Past 30 days'
              }
              filteredPartIds: [
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540a0'
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540a2'
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540a4'
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540a6'
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540a8'
                'StartboardPart-MonitorChartPart-03ebdb47-876e-4b83-a7f4-ee4b9e1540aa'
              ]
            }
          }
        }
      }
    }
  }
  name: dashboardName
  location: location
  tags: {}
}
