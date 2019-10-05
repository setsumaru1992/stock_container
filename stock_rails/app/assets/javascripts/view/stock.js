let initialVisiblityMap = {
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

visiblityMap = {}

$(function(){
  initializeVisibleMap()
  reflectVisibleMapToView()
})

function initializeVisibleMap(){
  updateVisibleMapFromCookie()
  if(Object.keys(visiblityMap).length === 0){
    visiblityMap = initialVisiblityMap
  }
}

const VISIBLE_MAP_KEY = "vmk"

function updateVisibleMapOfCookie(){
  window.document.cookie = `${VISIBLE_MAP_KEY}=${JSON.stringify(visiblityMap)}`
}

function updateVisibleMapFromCookie(){
  if(VISIBLE_MAP_KEY in cookies()){
    visiblityMap = JSON.parse(cookies()[VISIBLE_MAP_KEY])
  }
}

function cookies(){
  const cookieStr = window.document.cookie
  const cookieArray = cookieStr.split(";")

  return cookieArray.reduce((cookies, cookie) => {
    const cookieKeyValue = cookie.split("=")
    cookies[cookieKeyValue[0]] = cookieKeyValue[1]
    return cookies
  }, {})
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
  reflectVisibleMapToView()
}

function switchFieldsVisiblity(category){
  const categoryVisiblity = $(buildSelectorId(category)).prop('checked')
  Object.keys(visiblityMap[category]).forEach(field => {
    visiblityMap[category][field] = categoryVisiblity
    $(buildSelectorId(field)).prop('checked', categoryVisiblity)
  })
  reflectVisibleMapToView()
}

function reflectVisibleMapToView(){
  Object.keys(visiblityMap).forEach(category => {
    Object.keys(visiblityMap[category]).forEach(field => {
      if(visiblityMap[category][field]){
        $(`.${field}`).show()
        $(buildSelectorId(field)).prop('checked', true)
      } else {
        $(`.${field}`).hide()
        $(buildSelectorId(field)).prop('checked', false)
      }
    })
  })
  updateVisibleMapOfCookie()
}