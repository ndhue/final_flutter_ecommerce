final List<Map<String, dynamic>> orders = [
  {
    "id": "orderId1",
    "createdAt": "2025-02-18T15:30:45Z",
    "orderStatus": "Cancelded",
    "loyaltyPointsEarned": 365000,
    "loyaltyPointsUsed": 0,
    "total": 36500000,
    "orderDetails": [
      {
        "id": "productId1",
        "name": "Gaming Laptop",
        "variant": "16GB RAM - 512GB SSD",
        "price": 20000000,
        "discountApplied": 10,
        "finalPrice": "18000000",
        "quantity": 2,
      },
      {
        "id": "productId2",
        "name": "Wireless Mouse",
        "variant": "Black",
        "price": 500000,
        "discountApplied": 0,
        "finalPrice": 500000,
        "quantity": 1,
      },
    ],
    "statusHistory": [
      {
        "status": "Pending",
        "timestamp": "2025-02-18T15:30:45Z",
      },
      {
        "status": "Cancel",
        "timestamp": "2025-03-02T00:00:00Z",
      },
    ],
    "user": {
      "id": "userId1",
      "fullName": "John Doe",
      "email": "user@example.com",
      "shippingAddress": "123 Main St",
    },
  },
  {
    "id": "orderId2",
    "createdAt": "2025-04-03T09:12:00Z",
    "orderStatus": "Completed",
    "loyaltyPointsEarned": 5000,
    "loyaltyPointsUsed": 1000,
    "total": 3000000,
    "orderDetails": [
      {
        "id": "productId3",
        "name": "Bluetooth Speaker",
        "variant": "Red",
        "price": 1500000,
        "discountApplied": 0,
        "finalPrice": 1500000,
        "quantity": 2,
      }
    ],
    "statusHistory": [
      {
        "status": "Processing",
        "timestamp": "2025-04-03T09:12:00Z",
      },
      {
        "status": "Completed",
        "timestamp": "2025-04-04T15:00:00Z",
      },
    ],
    "user": {
      "id": "userId2",
      "fullName": "Jane Smith",
      "email": "jane@example.com",
      "shippingAddress": "456 River St",
    },
  },
  {
    "id": "orderId3",
    "createdAt": "2025-04-01T10:30:00Z",
    "orderStatus": "Completed",
    "loyaltyPointsEarned": 8000,
    "loyaltyPointsUsed": 2000,
    "total": 5600000,
    "orderDetails": [
      {
        "id": "productId4",
        "name": "Mechanical Keyboard",
        "variant": "RGB",
        "price": 2800000,
        "discountApplied": 0,
        "finalPrice": 2800000,
        "quantity": 2,
      }
    ],
    "statusHistory": [
      {
        "status": "Processing",
        "timestamp": "2025-04-01T10:30:00Z",
      },
      {
        "status": "Completed",
        "timestamp": "2025-04-03T14:45:00Z",
      },
    ],
    "user": {
      "id": "userId3",
      "fullName": "David Tran",
      "email": "david@example.com",
      "shippingAddress": "789 Hilltop Ave",
    },
  },
  {
    "id": "orderId4",
    "createdAt": "2025-03-25T08:00:00Z",
    "orderStatus": "Cancelled",
    "loyaltyPointsEarned": 0,
    "loyaltyPointsUsed": 0,
    "total": 999000,
    "orderDetails": [
      {
        "id": "productId5",
        "name": "Smartwatch",
        "variant": "Black",
        "price": 999000,
        "discountApplied": 0,
        "finalPrice": 999000,
        "quantity": 1,
      }
    ],
    "statusHistory": [
      {
        "status": "Pending",
        "timestamp": "2025-03-25T08:00:00Z",
      },
      {
        "status": "Cancel",
        "timestamp": "2025-03-27T12:00:00Z",
      },
    ],
    "user": {
      "id": "userId4",
      "fullName": "Linh Nguyen",
      "email": "linh@example.com",
      "shippingAddress": "999 Cloud St",
    },
  },

  {
    "id": "orderId5",
    "createdAt": "2025-04-08T10:00:00Z",
    "orderStatus": "Pending",
    "loyaltyPointsEarned": 2000,
    "loyaltyPointsUsed": 0,
    "total": 2000000,
    "orderDetails": [
      {
        "id": "productId6",
        "name": "USB-C Hub",
        "variant": "5-in-1",
        "price": 1000000,
        "discountApplied": 0,
        "finalPrice": 1000000,
        "quantity": 2,
      }
    ],
    "statusHistory": [
      {
        "status": "Pending",
        "timestamp": "2025-04-08T10:00:00Z",
      }
    ],
    "user": {
      "id": "userId5",
      "fullName": "Minh Vu",
      "email": "minh@example.com",
      "shippingAddress": "11 Sunset Blvd",
    },
  },

  // Đơn hàng trạng thái Delivered
  {
    "id": "orderId6",
    "createdAt": "2025-04-07T14:30:00Z",
    "orderStatus": "Delivered",
    "loyaltyPointsEarned": 3000,
    "loyaltyPointsUsed": 500,
    "total": 3000000,
    "orderDetails": [
      {
        "id": "productId7",
        "name": "4K Monitor",
        "variant": "27 inch",
        "price": 3000000,
        "discountApplied": 0,
        "finalPrice": 3000000,
        "quantity": 1,
      }
    ],
    "statusHistory": [
      {
        "status": "Processing",
        "timestamp": "2025-04-07T14:30:00Z",
      },
      {
        "status": "Delivered",
        "timestamp": "2025-04-08T18:00:00Z",
      }
    ],
    "user": {
      "id": "userId6",
      "fullName": "An Le",
      "email": "an@example.com",
      "shippingAddress": "88 Bamboo Rd",
    },
  },
];
