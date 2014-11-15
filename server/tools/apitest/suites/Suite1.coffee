
requestList = exports.requestList = []

requestList.push
  path: "/user/user1/delete"
  body: {}

requestList.push
  path: "/place/place1/delete"
  body: {}

requestList.push
  path: "/place/from_google_id/place1/delete"
  body: {}


requestList.push
  path: "/place/new"
  body:
    id: "place1"
    name: "Fake Place 1"
    location: "30,102"
    google_id: "place1"

requestList.push
  path: "/user/new"
  body:
    id: "user1"
    email: "user1@fake.com"

requestList.push
  path: "/user/user1/place/place1/review"
  body:
    review:
      description: "It was OK"
