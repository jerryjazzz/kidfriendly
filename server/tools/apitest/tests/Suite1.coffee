
requestList = exports.requestList = []

requestList.push
  path: "/api/user/user1/delete"
  body: {}

requestList.push
  path: "/api/place/place1/delete"
  body: {}

requestList.push
  path: "/api/place/from_google_id/place1/delete"
  body: {}

requestList.push
  path: "/api/place/new"
  body:
    place_id: "place1"
    name: "Fake Place 1"
    location: "30,102"
    google_id: "place1"

requestList.push
  path: "/api/user/new"
  body:
    user_id: "user1"
    email: "user1@fake.com"

requestList.push
  path: "/api/user/user1/place/place1/review"
  body:
    review:
      description: "It was OK"
