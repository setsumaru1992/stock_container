$(function(){
  reflectRowVisiblity()
})

let visiblityMap = {
  chart: {
    chart: true,
  },

  base: {
    category: true,
    feature: true,
    price: true,
    market_capitalization: true,
    listed_year: true,
  },

  grade: {
    latest_net_sales: true,
    latest_operating_income: true,
    latest_ordinary_income: true,
    latest_net_income: true,
    per: true,
    pbr: true,
  },

  cross: {
    day_golden_cross: false,
    day_dead_cross: false,
    week_golden_cross: false,
    week_dead_cross: false,
  }
}

function buildSelectorId(field){
  return `#display_${field}`
}

function switchVisiblity(field){
  visiblitySetting = {}
  visiblitySetting[field] = $(buildSelectorId(field)).prop('checked')

  Object.keys(visiblitySetting).forEach(field => {
    Object.keys(visiblityMap).forEach(category => {
      if(field in visiblityMap[category]){
        visiblityMap[category][field] = visiblitySetting[field]
      }
    })
  })
  reflectRowVisiblity()
}

function switchFieldsVisiblity(category){
  const categoryVisiblity = $(buildSelectorId(category)).prop('checked')
  Object.keys(visiblityMap[category]).forEach(field => {
    visiblityMap[category][field] = categoryVisiblity
    $(buildSelectorId(field)).prop('checked', categoryVisiblity)
  })
  reflectRowVisiblity()
}

function reflectRowVisiblity(){
  Object.keys(visiblityMap).forEach(category => {
    Object.keys(visiblityMap[category]).forEach(field => {
      if(visiblityMap[category][field]){
        $(`.${field}`).show()
      } else {
        $(`.${field}`).hide()
      }
    })
  })
}